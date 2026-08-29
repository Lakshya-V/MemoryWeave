import os
import json
import uuid
from typing import List
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="MemoryWeave Backend Engine")

# Enable CORS for Flutter app and web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Reka AI client via OpenAI-compatible endpoint with explicit timeout
REKA_API_KEY = os.getenv("REKA_API_KEY", "your_reka_api_key_here")
reka_client = OpenAI(
    base_url="https://api.reka.ai/v1",
    api_key=REKA_API_KEY,
    timeout=60.0
)

# Shared In-Memory Storage
MEMORIES_DB = [
    {
        "memory_id": "mem_001",
        "image_url": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
        "qa_pairs": [
            {"question": "Who is with you in this photo?", "answer": "Sunita and Rohan"},
            {"question": "Where was this vacation taken?", "answer": "Goa Beach"},
            {"question": "What year was this taken?", "answer": "1995"}
        ],
        "ground_truth": "Who is with you in this photo?: Sunita and Rohan | Where was this vacation taken?: Goa Beach | What year was this taken?: 1995"
    }
]

current_index = 0

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

# 1. Caregiver Step A: Reka inspects photo and generates 3 questions for caregiver
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

# 2. Caregiver Step B: Save caregiver answers and form ground truth
@app.post("/caregiver/save-memory")
async def save_memory(req: SaveMemoryRequest):
    ground_truth_parts = [f"{pair.question}: {pair.answer}" for pair in req.qa_pairs]
    ground_truth_summary = " | ".join(ground_truth_parts)

    new_memory = {
        "memory_id": f"mem_{uuid.uuid4().hex[:6]}",
        "image_url": req.image_url,
        "qa_pairs": [pair.dict() for pair in req.qa_pairs],
        "ground_truth": ground_truth_summary
    }

    MEMORIES_DB.append(new_memory)
    return {"status": "success", "memory_id": new_memory["memory_id"], "total_memories": len(MEMORIES_DB)}

# 3. Elder Game: Serve next photo and a recall question
@app.get("/activity/next")
async def get_next_activity():
    global current_index
    
    if not MEMORIES_DB:
        raise HTTPException(status_code=404, detail="No memories available.")

    memory = MEMORIES_DB[current_index % len(MEMORIES_DB)]
    current_index += 1

    selected_qa = memory["qa_pairs"][0] if memory["qa_pairs"] else {
        "question": "Do you remember who was with you in this photo?",
        "answer": "Family"
    }

    return {
        "memory_id": memory["memory_id"],
        "image_url": memory["image_url"],
        "question_text": selected_qa["question"],
        "ground_truth": memory["ground_truth"]
    }

# 4. Elder Game: Flexible evaluation using entire memory context
@app.post("/activity/evaluate")
async def evaluate_answer(req: EvaluationRequest):
    memory = next((m for m in MEMORIES_DB if m["memory_id"] == req.memory_id), MEMORIES_DB[0])

    prompt = f"""
    Full Ground Truth Facts for this Photo:
    "{memory['ground_truth']}"

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