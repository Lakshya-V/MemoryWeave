from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, JSON
from sqlalchemy.sql import func
from database import Base

class Memory(Base):
    __tablename__ = "memories"
    
    memory_id = Column(String, primary_key=True, index=True)
    image_url = Column(String, nullable=False)
    qa_pairs = Column(JSON, nullable=False)  # Stores array of 5 QA objects
    ground_truth = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class ActivityLog(Base):
    __tablename__ = "activity_logs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String, default="user_default")
    memory_id = Column(String, nullable=False)
    transcribed_text = Column(String, nullable=False)
    latency_ms = Column(Integer, nullable=False)
    accuracy_score = Column(Float, nullable=False)
    match_type = Column(String, nullable=False)
    anomaly_flagged = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())