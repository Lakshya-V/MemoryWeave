import os
import json
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

# Initialize Reka AI client via OpenAI-compatible endpoint
REKA_API_KEY = os.getenv("REKA_API_KEY", "your_reka_api_key_here")
reka_client = OpenAI(
    base_url="https://api.reka.ai/v1",
    api_key=REKA_API_KEY
)

# Mock Memory Graph Dataset
MOCK_MEMORIES = [
    {
        "memory_id": "mem_001",
        "image_url": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
        "context_details": "Family vacation at Goa beach in 1995 with wife Sunita and son Rohan.",
        "ground_truth": "Sunita and Rohan at Goa beach"
    },
    {
        "memory_id": "mem_002",
        "image_url": "https://images.unsplash.com/photo-1511795409834-ef04bbd61622",
        "context_details": "Sunita and Ramesh's wedding anniversary in New Delhi in 1988.",
        "ground_truth": "Wedding anniversary celebration with family in Delhi"
    }
]

current_memory_index = 0


class EvaluationRequest(BaseModel):
    memory_id: str
    transcribed_text: str
    latency_ms: int


@app.get("/")
async def root():
    return {"status": "online", "system": "MemoryWeave Core API"}


@app.get("/activity/next")
async def get_next_activity():
    global current_memory_index
    memory = MOCK_MEMORIES[current_memory_index]
    current_memory_index = (current_memory_index + 1) % len(MOCK_MEMORIES)

    try:
        response = reka_client.chat.completions.create(
            model="reka-flash-3",
            messages=[
                {
                    "role": "system",
                    "content": "You are a warm memory assistant. Generate a single recall question. STRICT RULE: NEVER reveal the names, exact locations, or specific people mentioned in the context. Ask who or what they see."
                },
                {
                    "role": "user",
                    "content": f"Context: {memory['context_details']}\n\nAsk the user a short question to test if they remember who is with them in this photo without giving away their names."
                }
            ],
            temperature=0.2,
            max_tokens=50
        )
        question_text = response.choices[0].message.content.strip()
        question_text = question_text.replace('"', '').replace('\n', ' ')

        if not question_text or len(question_text) > 120:
            question_text = "Do you remember who was with you in this special photo?"

    except Exception as e:
        print(f"REKA API ERROR: {e}")
        question_text = "Do you remember who was with you in this special photo?"

    return {
        "memory_id": memory["memory_id"],
        "image_url": memory["image_url"],
        "question_text": question_text,
        "ground_truth": memory["ground_truth"]
    }


@app.post("/activity/evaluate")
async def evaluate_answer(req: EvaluationRequest):
    """
    Receives user voice transcription and latency, grades accuracy via Reka AI.
    """
    memory = next((m for m in MOCK_MEMORIES if m["memory_id"] == req.memory_id), MOCK_MEMORIES[0])

    prompt = f"""
    Ground Truth Fact: "{memory['ground_truth']}"
    User Response: "{req.transcribed_text}"

    Compare response to ground truth. Output ONLY valid JSON:
    {{"score": 100, "feedback": "Wonderful job! You remembered Sunita and Rohan."}}

    RULES:
    - "score": integer 0-100 based on accuracy.
    - "feedback": 1 short, encouraging, warm sentence (5–8 words) for an elderly person. Never use clinical or technical words.
    """

    try:
        response = reka_client.chat.completions.create(
            model="reka-flash-3",
            messages=[{"role": "user", "content": prompt}]
        )
        raw_output = response.choices[0].message.content.strip()
        
        # Clean potential markdown formatting in model output
        if raw_output.startswith("```json"):
            raw_output = raw_output.replace("```json", "").replace("```", "").strip()

        parsed = json.loads(raw_output)
        score = int(parsed.get("score", 75))
        feedback = parsed.get("feedback", "Great job sharing that memory!")
    except Exception:
        score = 80 if len(req.transcribed_text) > 3 else 30
        feedback = "Thank you for sharing that with me!"

    return {
        "memory_id": req.memory_id,
        "accuracy_score": score,
        "is_correct": score >= 60,
        "latency_ms": req.latency_ms,
        "feedback_text": feedback,
        "anomaly_flagged": False
    }