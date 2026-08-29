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
from ml.anomaly import detect_drift

from database import engine, Base, get_db
import models
import base64
import requests

def to_base64_data_uri(image_input: str) -> str:
    """
    Converts a web URL or raw base64 string into a formatted Base64 Data URI.
    """
    # 1. If Flutter already sent a formatted Base64 string, return as-is
    if image_input.startswith("data:image"):
        return image_input

    # 2. If it's a web URL, fetch image bytes on your backend and encode them
    if image_input.startswith(("http://", "https://")):
        try:
            response = requests.get(image_input, timeout=5.0)
            response.raise_for_status()
            
            mime_type = response.headers.get("Content-Type", "image/jpeg")
            encoded_bytes = base64.b64encode(response.content).decode("utf-8")
            return f"data:{mime_type};base64,{encoded_bytes}"
        except Exception as e:
            print(f"FAILED TO FETCH/ENCODE IMAGE URL: {e}")
            raise HTTPException(status_code=400, detail="Could not retrieve image from provided URL.")

    # 3. If raw base64 without prefix, append standard jpeg header
    return f"data:image/jpeg;base64,{image_input}"

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
    timeout=12.0  # Fails fast & returns fallback before DevTunnel times out!
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

# Kept async def: Light weight, non-blocking simple dictionary return
@app.get("/")
async def root():
    return {"status": "online", "system": "MemoryWeave Core Engine"}

# 1. Caregiver Step A: Reka inspects photo (CHANGED TO def -> offloads blocking Reka SDK call)
@app.post("/caregiver/generate-questions")
def generate_caregiver_questions(req: CaregiverQuestionsRequest):
    # Convert incoming URL or Base64 string to a Reka-compatible Data URI
    try:
        base64_image_uri = to_base64_data_uri(req.image_url)
    except HTTPException as http_err:
        raise http_err
    except Exception:
        base64_image_uri = req.image_url  # Fallback to original string

    max_retries = 2
    for attempt in range(max_retries):
        try:
            response = reka_client.chat.completions.create(
                model="reka-edge",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "image_url", "image_url": {"url": base64_image_uri}},
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
            return {"image_url": req.image_url, "questions": questions}

        except Exception as e:
            print(f"REKA VISION ATTEMPT {attempt + 1} FAILED: {e}")

    # Fallback returned instantly if Reka times out or errors out
    return {
        "image_url": req.image_url,
        "questions": [
            "Who are the people present in this photo?",
            "Where was this photo taken?",
            "What special memory or event is captured here?"
        ]
    }

# 2. Caregiver Step B: Save answers (CHANGED TO def -> offloads synchronous SQLAlchemy)
@app.post("/caregiver/save-memory")
def save_memory(req: SaveMemoryRequest, db: Session = Depends(get_db)):
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

# 3. Elder Game: Serve next photo (CHANGED TO def -> offloads synchronous SQLAlchemy)
@app.get("/activity/next")
def get_next_activity(db: Session = Depends(get_db)):
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

# 4. Elder Game: Evaluate answer (CHANGED TO def -> offloads Reka SDK + SQLAlchemy + ML calls)
@app.post("/activity/evaluate")
def evaluate_answer(req: EvaluationRequest, db: Session = Depends(get_db)):
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

    # Step 1: Reka evaluates transcription
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

    # Step 2: Feed score and latency into ML anomaly detector
    try:
        drift_result = detect_drift(
            user_id="user_default",
            latency_ms=float(req.latency_ms),
            accuracy_score=float(score)
        )
        is_anomaly = drift_result.get("anomaly_flagged", False)
    except Exception as e:
        print(f"ML ANOMALY ERROR: {e}")
        is_anomaly = False

    # Step 3: Return integrated results
    return {
        "memory_id": req.memory_id,
        "accuracy_score": score,
        "match_type": match_type,
        "is_correct": score >= 60,
        "latency_ms": req.latency_ms,
        "feedback_text": feedback,
        "anomaly_flagged": is_anomaly
    }