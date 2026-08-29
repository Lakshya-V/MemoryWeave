from sqlalchemy import Column, String, JSON
from database import Base

class Memory(Base):
    __tablename__ = "memories"

    memory_id = Column(String, primary_key=True, index=True)
    image_url = Column(String, nullable=False)
    qa_pairs = Column(JSON, nullable=False)  # Stores dynamic list of {"question": "", "answer": ""}
    ground_truth = Column(String, nullable=False)