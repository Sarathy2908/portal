from fastapi import APIRouter, HTTPException
from app.core.queue_manager import process_queue
import os

router = APIRouter()

@router.post("/process-queue")
async def trigger_queue_processing():
    """
    Manual endpoint to trigger queue processing.
    For Vercel serverless deployment, this replaces the background worker.
    Call this endpoint periodically (e.g., via cron job or after submission).
    """
    try:
        await process_queue()
        return {"message": "Queue processing triggered successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Queue processing failed: {str(e)}")

@router.get("/process-queue-status")
async def get_processing_status():
    """
    Check if running on Vercel (serverless) or traditional server.
    """
    is_vercel = os.getenv("VERCEL") == "1"
    return {
        "is_serverless": is_vercel,
        "mode": "serverless" if is_vercel else "traditional",
        "note": "On serverless, call /process-queue to trigger evaluation" if is_vercel else "Background worker is running"
    }
