import os
import json
import uuid
import random
import base64
import requests
from typing import List

import pandas as pd
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
from sqlalchemy.orm import Session

from database import engine, Base, get_db
import models
from ml.anomaly import detect_drift, evaluate_behavioral_state, generate_explanation

load_dotenv()

# Initialize Database Tables
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
    timeout=15.0
)

def format_image_for_llm(image_input: str) -> str:
    """
    Optimizes image delivery: passes HTTP/HTTPS URLs directly to reduce latency,
    and formats raw base64 inputs as Data URIs.
    """
    if image_input.startswith(("http://", "https://", "data:image")):
        return image_input

    # Treat as raw Base64 string if no URL scheme is present
    return f"data:image/jpeg;base64,{image_input}"

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

# 1. Caregiver Step A: Generate questions
@app.post("/caregiver/generate-questions")
def generate_caregiver_questions(req: CaregiverQuestionsRequest):
    formatted_image = format_image_for_llm(req.image_url)

    prompt_text = """Look at this image and generate EXACTLY 5 short, warm, playful and conversation-starting prompts for an elderly person. The goal is to make them WANT to interact, smile, recognize familiar things, and share their own memories. The interaction should feel like a friendly companion looking at a photo with them, NOT like a test, interview, quiz, medical assessment, or interrogation.

Use visible people, their positions, and interesting objects as gentle memory cues. If a person is visible on the left, right, or center, invite recognition naturally, for example: 'Oh, do you happen to recognize the lovely person on the left?' Do not invent their name or relationship. If an interesting object is visible, use it to spark curiosity. For example, for a wrapped gift: 'Ooh, I wonder if this little gift brings back a memory... do you remember what was inside?' For a cake: 'That cake looks special! Does it remind you of a happy moment?' Do not assume it was a birthday. For a familiar-looking place: 'This place looks interesting! Does it bring back any memories for you?'

The elderly person should provide the meaning and backstory. NEVER invent the backstory yourself. Never assume a wedding, birthday, trip, family relationship, location, date, occasion, or event. Never ask them to guess, infer, estimate, or prove anything. Never use phrases such as 'Who is...', 'Where is...', 'What is...', 'What do you think...', or 'Can you identify...' in a demanding or test-like way.

Prefer gentle conversational phrases such as 'Do you happen to remember...', 'Does this bring back a memory...', 'This looks familiar...', 'I wonder if...', 'Oh, look at...', 'Does this remind you of...', and 'Would you like to tell me about...'. Keep the tone respectful, affectionate, curious, and encouraging. Avoid childish language, talking down to the person, excessive praise, or sounding like a caregiver giving instructions.

Make each prompt easy to understand and enjoyable to respond to. The image provides the CUE; the elderly person provides the STORY. Return ONLY a valid JSON array containing exactly 5 strings, using double quotes."""

    try:
        response = reka_client.chat.completions.create(
            model="reka-edge",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "image_url", "image_url": {"url": formatted_image}},
                        {"type": "text", "text": prompt_text.strip()}
                    ]
                }
            ],
            max_tokens=250,
            temperature=0.0
        )
        
        raw_out = response.choices[0].message.content.strip()
        if raw_out.startswith("```json"):
            raw_out = raw_out.replace("```json", "").replace("```", "").strip()
        elif raw_out.startswith("```"):
            raw_out = raw_out.replace("```", "").strip()

        parsed_json = json.loads(raw_out)
        
        if isinstance(parsed_json, dict):
            questions = parsed_json.get("questions", [])
        elif isinstance(parsed_json, list):
            questions = parsed_json
        else:
            questions = []

        if isinstance(questions, list) and len(questions) == 5:
            return {"image_url": req.image_url, "questions": questions}

    except Exception as e:
        print(f"REKA VISION INFERENCE ERROR: {e}")

    # Immediate fallback response if LLM request times out or fails
    return {
        "image_url": req.image_url,
        "questions": [
            "Does looking at this photo bring a gentle feeling of comfort?",
            "Do you remember the warm feeling of this day?",
            "Does seeing this moment bring back a happy memory for you?",
            "Does this peaceful scene feel familiar to your heart?",
            "Would you like to share what soft memory comes to mind looking at this?"
        ]
    }

# 2. Caregiver Step B: Save answers
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

@app.get("/caregiver/memories")
def list_memories(db: Session = Depends(get_db)):
    memories = db.query(models.Memory).order_by(models.Memory.created_at.desc()).all()

    results = []
    for memory in memories:
        logs = db.query(models.ActivityLog).filter(
            models.ActivityLog.memory_id == memory.memory_id
        ).all()

        times_prompted = len(logs)
        avg_accuracy = (
            round(sum(log.accuracy_score for log in logs) / times_prompted)
            if times_prompted > 0
            else 0
        )

        results.append({
            "memory_id": memory.memory_id,
            "image_url": memory.image_url,
            "ground_truth": memory.ground_truth,
            "created_at": memory.created_at.isoformat() if memory.created_at else None,
            "times_prompted": times_prompted,
            "avg_recall_accuracy": avg_accuracy,
        })

    return {"memories": results, "total": len(results)}

# 3. Elder Game: Serve random photo with question prompts
@app.get("/activity/next")
def get_next_activity(db: Session = Depends(get_db)):
    all_memories = db.query(models.Memory).all()

    if not all_memories:
        raise HTTPException(status_code=404, detail="No memories available in database.")

    memory = random.choice(all_memories)
    questions = [qa["question"] for qa in memory.qa_pairs] if memory.qa_pairs else []

    return {
        "memory_id": memory.memory_id,
        "image_url": memory.image_url,
        "questions": questions,
        "qa_pairs": memory.qa_pairs,
        "ground_truth": memory.ground_truth
    }

# 4. Elder Game: Evaluate answer and record session log
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
    {{"score": 85, "match_type": "partial_context", "feedback": "Wonderful! That was indeed a warm memory."}}

    SCORING RULES:
    - "direct_answer" (score 90-100): Correctly answers the specific question asked.
    - "partial_context" (score 75-85): Mentioned ANY valid detail from ground truth.
    - "incorrect" (score 0-40): Inaccurate or states they cannot remember.
    - "feedback": 1 short encouraging sentence (5-8 words).
    """

    try:
        response = reka_client.chat.completions.create(
            model="reka-edge",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=150,
            temperature=0.0
        )
        raw_out = response.choices[0].message.content.strip()
        if raw_out.startswith("```json"):
            raw_out = raw_out.replace("```json", "").replace("```", "").strip()
        elif raw_out.startswith("```"):
            raw_out = raw_out.replace("```", "").strip()

        parsed = json.loads(raw_out)
        score = int(parsed.get("score", 75))
        match_type = parsed.get("match_type", "partial_context")
        feedback = parsed.get("feedback", "Great job sharing that memory!")
    except Exception as e:
        print(f"REKA EVALUATION ERROR: {e}")
        score = 80 if len(req.transcribed_text) > 3 else 30
        match_type = "partial_context" if score >= 60 else "incorrect"
        feedback = "Thank you for sharing that with me!"

    drift_result = detect_drift(
        user_id="user_default",
        latency_ms=float(req.latency_ms),
        accuracy_score=float(score)
    )
    is_anomaly = drift_result.get("anomaly_flagged", False)

    log_entry = models.ActivityLog(
        user_id="user_default",
        memory_id=req.memory_id,
        transcribed_text=req.transcribed_text,
        latency_ms=req.latency_ms,
        accuracy_score=float(score),
        match_type=match_type,
        anomaly_flagged=is_anomaly
    )
    db.add(log_entry)
    db.commit()

    return {
        "memory_id": req.memory_id,
        "accuracy_score": score,
        "match_type": match_type,
        "is_correct": score >= 60,
        "latency_ms": req.latency_ms,
        "feedback_text": feedback,
        "anomaly_flagged": is_anomaly
    }

# 5. Caregiver Dashboard: Behavioral analysis
@app.get("/caregiver/dashboard")
def get_caregiver_dashboard(user_id: str = "user_default", db: Session = Depends(get_db)):
    logs = db.query(models.ActivityLog).filter(models.ActivityLog.user_id == user_id).all()

    if not logs:
        return {
            "status": "insufficient_data",
            "message": "No session history recorded yet.",
            "state": "stable"
        }

    data = []
    for log in logs:
        data.append({
            "accuracy": log.accuracy_score / 100.0,
            "avg_response_latency": log.latency_ms / 1000.0,
            "hint_rate": 0.0,
            "completion_rate": 1.0,
            "is_anomaly": 1 if log.anomaly_flagged else 0
        })

    df = pd.DataFrame(data)
    trends = evaluate_behavioral_state(df)
    latest_session = data[-1]
    
    baseline = {
        "accuracy_mean": 0.80,
        "avg_response_latency_mean": 5.0,
        "hint_rate_mean": 0.15,
        "completion_rate_mean": 0.90
    }
    
    explanation = generate_explanation(latest_session, trends, baseline)

    return {
        "user_id": user_id,
        "total_sessions": len(logs),
        "behavioral_state": trends["state"],
        "clinical_insight": explanation,
        "trend_metrics": trends
    }