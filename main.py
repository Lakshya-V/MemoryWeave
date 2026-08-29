import os
import json
import uuid
from typing import List
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
from sqlalchemy.orm import Session

from database import engine, Base, get_db
import models

load_dotenv()

# Initialize PostgreSQL tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="MemoryWeave Backend Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

REKA_API_KEY = os.getenv("REKA_API_KEY", "your_reka_api_key_here")
reka_client = OpenAI(
    base_url="https://api.reka.ai/v1",
    api_key=REKA_API_KEY,
    timeout=60.0
)

# --- Pydantic Data Schemas ---

class CaregiverQuestionsRequest(BaseModel):
    image_url: str

class CaregiverQAPair(BaseModel):
    question: str
    answer: str

class SaveMemoryRequest(BaseModel):
    image_url: str
    qa_pairs: List[CaregiverQAPair]

class EvaluationRequest(BaseModel):
    memory_id: str
    transcribed_text: str
    latency_ms: int

# --- API Endpoints ---

@app.get("/")
async def root():
    return {"status": "online", "system": "MemoryWeave Core Engine"}

# 1. Caregiver Step A: Reka inspects photo and generates 3 questions
@app.post("/caregiver/generate-questions")
async def generate_caregiver_questions(req: CaregiverQuestionsRequest):
    try:
        response = reka_client.chat.completions.create(
            model="reka-edge",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "image_url", "image_url": {"url": req.image_url}},
                        {
                            "type": "text",
                            "text": (
                                "Look at this photo. Generate EXACTLY 3 short questions to ask the caregiver: "
                                "1 about the people in it, 1 about the location, and 1 about the event/year. "
                                "Return ONLY a valid JSON list of strings like: "
                                '["Who is with you in this photo?", "Where was this taken?", "What event was this?"]'
                            )
                        }
                    ]
                }
            ]
        )
        raw_out = response.choices[0].message.content.strip()
        if raw_out.startswith("```json"):
            raw_out = raw_out.replace("```json", "").replace("```", "").strip()
            
        questions = json.loads(raw_out)
    except Exception as e:
        print(f"REKA VISION ERROR: {e}")
        questions = [
            "Who are the people present in this photo?",
            "Where was this photo taken?",
            "What special memory or event is captured here?"
        ]

    return {"image_url": req.image_url, "questions": questions}

# 2. Caregiver Step B: Save caregiver answers into PostgreSQL
@app.post("/caregiver/save-memory")
async def save_memory(req: SaveMemoryRequest, db: Session = Depends(get_db)):
    ground_truth_parts = [f"{pair.question}: {pair.answer}" for pair in req.qa_pairs]
    ground_truth_summary = " | ".join(ground_truth_parts)

    new_memory = models.Memory(
        memory_id=f"mem_{uuid.uuid4().hex[:6]}",
        image_url=req.image_url,
        qa_pairs=[pair.dict() for pair in req.qa_pairs],
        ground_truth=ground_truth_summary
    )

    db.add(new_memory)
    db.commit()
    db.refresh(new_memory)

    total_memories = db.query(models.Memory).count()
    return {"status": "success", "memory_id": new_memory.memory_id, "total_memories": total_memories}

# 3. Elder Game: Serve next photo from PostgreSQL database
@app.get("/activity/next")
async def get_next_activity(db: Session = Depends(get_db)):
    memory = db.query(models.Memory).first()
    
    if not memory:
        raise HTTPException(status_code=404, detail="No memories available in database.")

    selected_qa = memory.qa_pairs[0] if memory.qa_pairs else {
        "question": "Do you remember who was with you in this photo?",
        "answer": "Family"
    }

    return {
        "memory_id": memory.memory_id,
        "image_url": memory.image_url,
        "question_text": selected_qa["question"],
        "ground_truth": memory.ground_truth
    }

# 4. Elder Game: Reka evaluates spoken answer against PostgreSQL ground truth
@app.post("/activity/evaluate")
async def evaluate_answer(req: EvaluationRequest, db: Session = Depends(get_db)):
    memory = db.query(models.Memory).filter(models.Memory.memory_id == req.memory_id).first()

    if not memory:
        raise HTTPException(status_code=404, detail="Memory record not found.")

    prompt = f"""
    Full Ground Truth Facts for this Photo:
    "{memory.ground_truth}"

    Elder's Response: "{req.transcribed_text}"

    Compare the elder's response against the full ground truth facts. 
    Output ONLY valid JSON in this exact structure:
    {{"score": 85, "match_type": "partial_context", "feedback": "Wonderful! That was indeed at Goa beach."}}

    SCORING RULES:
    - "direct_answer" (score 90-100): Correctly answers the specific question asked.
    - "partial_context" (score 75-85): Mentioned ANY valid detail from ground truth (e.g., location or year instead of person). Grant partial credit!
    - "incorrect" (score 0-40): Completely inaccurate or states they cannot remember.
    - "feedback": 1 short, encouraging sentence (5-8 words) for an elderly person.
    """

    try:
        response = reka_client.chat.completions.create(
            model="reka-edge",
            messages=[{"role": "user", "content": prompt}]
        )
        raw_out = response.choices[0].message.content.strip()
        if raw_out.startswith("```json"):
            raw_out = raw_out.replace("```json", "").replace("```", "").strip()

        parsed = json.loads(raw_out)
        score = int(parsed.get("score", 75))
        match_type = parsed.get("match_type", "partial_context")
        feedback = parsed.get("feedback", "Great job sharing that memory!")
    except Exception as e:
        print(f"REKA EVALUATION ERROR: {e}")
        score = 80 if len(req.transcribed_text) > 3 else 30
        match_type = "partial_context" if score >= 60 else "incorrect"
        feedback = "Thank you for sharing that with me!"

    return {
        "memory_id": req.memory_id,
        "accuracy_score": score,
        "match_type": match_type,
        "is_correct": score >= 60,
        "latency_ms": req.latency_ms,
        "feedback_text": feedback,
        "anomaly_flagged": False
    }