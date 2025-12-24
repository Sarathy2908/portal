from pydantic import BaseModel, HttpUrl
from typing import Optional, List
from datetime import datetime
from enum import Enum

class QueueStatus(str, Enum):
    QUEUED = "QUEUED"
    EVALUATING = "EVALUATING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class TeamSubmission(BaseModel):
    team_id: str
    team_name: str
    endpoint_url: str

class TeamInDB(BaseModel):
    team_id: str
    team_name: str
    endpoint_url: str
    created_at: datetime

class QueueEntry(BaseModel):
    team_id: str
    status: QueueStatus
    position: int
    queued_at: datetime
    failure_reason: Optional[str] = None

class EvaluationResult(BaseModel):
    team_id: str
    accuracy: float
    f1_score: float
    latency_ms: float
    evaluated_at: datetime

class PlagiarismCase(BaseModel):
    team_id: str
    similarity_score: float
    detected_at: datetime

class PlagiarismSummary(BaseModel):
    is_flagged: bool
    similar_teams_count: int
    highest_similarity: float
    similar_teams: List[str]

class LeaderboardEntry(BaseModel):
    rank: int
    team_id: str
    team_name: str
    accuracy: float
    f1_score: float
    latency_ms: float
    evaluated_at: datetime
    is_plagiarized: Optional[bool] = False
    plagiarism_summary: Optional[PlagiarismSummary] = None

class SubmitResponse(BaseModel):
    message: str
    team_id: str
    queue_position: int

class QueueStatusResponse(BaseModel):
    team_id: str
    status: QueueStatus
    position: Optional[int] = None
    estimated_wait_time: Optional[int] = None
    failure_reason: Optional[str] = None

class TeamResultResponse(BaseModel):
    team_id: str
    team_name: str
    rank: Optional[int] = None
    accuracy: Optional[float] = None
    f1_score: Optional[float] = None
    latency_ms: Optional[float] = None
    status: QueueStatus
    evaluated_at: Optional[datetime] = None
