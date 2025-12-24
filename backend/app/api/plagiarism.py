from fastapi import APIRouter, HTTPException
from typing import List, Dict, Optional
from app.db.firebase_service import get_plagiarism_data, get_all_plagiarism_flags
from app.db.models import PlagiarismSummary

router = APIRouter()

@router.get("/plagiarism/{team_id}")
async def get_team_plagiarism(team_id: str):
    plagiarism_data = get_plagiarism_data(team_id)
    
    if not plagiarism_data:
        return {
            "team_id": team_id,
            "is_flagged": False,
            "message": "No plagiarism data available for this team"
        }
    
    return {
        "team_id": team_id,
        "is_flagged": plagiarism_data.get('is_flagged', False),
        "plagiarism_cases": plagiarism_data.get('plagiarism_cases', []),
        "checked_at": plagiarism_data.get('checked_at')
    }

@router.get("/plagiarism-summary")
async def get_plagiarism_summary():
    flags = get_all_plagiarism_flags()
    
    total_teams = len(flags)
    flagged_teams = sum(1 for is_flagged in flags.values() if is_flagged)
    
    return {
        "total_teams_checked": total_teams,
        "flagged_teams_count": flagged_teams,
        "clean_teams_count": total_teams - flagged_teams,
        "flagged_team_ids": [team_id for team_id, is_flagged in flags.items() if is_flagged]
    }
