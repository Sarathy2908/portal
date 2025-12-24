import asyncio
from app.db.firebase_service import (
    get_next_in_queue, 
    update_queue_status, 
    get_team_endpoint, 
    save_result,
    save_predictions,
    get_all_predictions,
    save_plagiarism_data
)
from app.db.models import QueueStatus
from app.core.evaluator import Evaluator
from app.core.plagiarism_detector import PlagiarismDetector
from app.config import MAX_CONCURRENT_EVALUATIONS

evaluator = Evaluator()
plagiarism_detector = PlagiarismDetector(similarity_threshold=0.95)

async def process_single_team(team_id):
    update_queue_status(team_id, QueueStatus.EVALUATING)
    
    endpoint_url = get_team_endpoint(team_id)
    
    if not endpoint_url:
        update_queue_status(team_id, QueueStatus.FAILED, "Endpoint URL not found")
        return
    
    try:
        success, result, error, predictions = await evaluator.evaluate_team(endpoint_url)
        
        if success and result and predictions:
            save_result(team_id, result["accuracy"], result["f1_score"], result["latency_ms"])
            
            save_predictions(team_id, predictions)
            
            all_predictions = get_all_predictions()
            plagiarism_cases = plagiarism_detector.detect_plagiarism(
                team_id, 
                predictions, 
                all_predictions
            )
            
            is_flagged = plagiarism_detector.is_plagiarized(plagiarism_cases)
            
            plagiarism_cases_serializable = [
                {
                    'team_id': case['team_id'],
                    'similarity_score': case['similarity_score'],
                    'detected_at': case['detected_at'].isoformat()
                }
                for case in plagiarism_cases
            ]
            save_plagiarism_data(team_id, plagiarism_cases_serializable, is_flagged)
            
            update_queue_status(team_id, QueueStatus.COMPLETED)
        else:
            update_queue_status(team_id, QueueStatus.FAILED, error or "Evaluation failed")
        
    except Exception as e:
        update_queue_status(team_id, QueueStatus.FAILED, str(e))

async def process_queue():
    team_id = get_next_in_queue()
    
    if not team_id:
        return
    
    await process_single_team(team_id)

async def process_queue_parallel():
    tasks = []
    
    for _ in range(MAX_CONCURRENT_EVALUATIONS):
        team_id = get_next_in_queue()
        if team_id:
            tasks.append(process_single_team(team_id))
    
    if tasks:
        await asyncio.gather(*tasks, return_exceptions=True)
