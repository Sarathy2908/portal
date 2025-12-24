import firebase_admin
from firebase_admin import credentials, firestore, auth
from datetime import datetime
from typing import List, Optional, Dict
from app.db.models import QueueStatus, TeamInDB, QueueEntry, EvaluationResult, LeaderboardEntry
from app.config import FIREBASE_CREDENTIALS_PATH
import os
import json

db = None

def init_firebase():
    global db
    if not firebase_admin._apps:
        # Try to load from environment variable first
        firebase_creds_json = os.getenv('FIREBASE_CREDENTIALS_JSON')
        
        if firebase_creds_json:
            # Load credentials from environment variable
            cred_dict = json.loads(firebase_creds_json)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
        elif os.path.exists(FIREBASE_CREDENTIALS_PATH):
            # Fallback to file-based credentials for local development
            cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred)
        else:
            # Use default credentials (for Google Cloud environments)
            firebase_admin.initialize_app()
        db = firestore.client()
    return db

def get_db():
    global db
    if db is None:
        db = init_firebase()
    return db

def add_team(team_id: str, team_name: str, endpoint_url: str, user_id: str) -> bool:
    db = get_db()
    team_ref = db.collection('teams').document(team_id)
    team_ref.set({
        'team_id': team_id,
        'team_name': team_name,
        'endpoint_url': endpoint_url,
        'user_id': user_id,
        'created_at': firestore.SERVER_TIMESTAMP
    }, merge=True)
    return True

def add_to_queue(team_id: str) -> int:
    db = get_db()
    
    queued_docs = db.collection('queue').where('status', '==', QueueStatus.QUEUED.value).stream()
    max_position = 0
    for doc in queued_docs:
        pos = doc.to_dict().get('position', 0)
        if pos > max_position:
            max_position = pos
    
    position = max_position + 1
    
    queue_ref = db.collection('queue').document(team_id)
    queue_ref.set({
        'team_id': team_id,
        'status': QueueStatus.QUEUED.value,
        'position': position,
        'queued_at': firestore.SERVER_TIMESTAMP,
        'failure_reason': None
    }, merge=True)
    
    return position

def get_queue_status(team_id: str) -> Optional[QueueEntry]:
    db = get_db()
    doc = db.collection('queue').document(team_id).get()
    
    if doc.exists:
        data = doc.to_dict()
        return QueueEntry(
            team_id=data['team_id'],
            status=QueueStatus(data['status']),
            position=data.get('position'),
            queued_at=data['queued_at'],
            failure_reason=data.get('failure_reason')
        )
    return None

def get_next_in_queue() -> Optional[str]:
    db = get_db()
    
    evaluating_docs = list(db.collection('queue').where('status', '==', QueueStatus.EVALUATING.value).limit(1).stream())
    if evaluating_docs:
        return None
    
    queued_docs = list(db.collection('queue').where('status', '==', QueueStatus.QUEUED.value).stream())
    
    if not queued_docs:
        return None
    
    queued_list = [{'team_id': doc.to_dict()['team_id'], 'position': doc.to_dict().get('position', 999)} for doc in queued_docs]
    queued_list.sort(key=lambda x: x['position'])
    
    if queued_list:
        return queued_list[0]['team_id']
    
    return None

def update_queue_status(team_id: str, status: QueueStatus, failure_reason: Optional[str] = None):
    db = get_db()
    queue_ref = db.collection('queue').document(team_id)
    queue_ref.update({
        'status': status.value,
        'failure_reason': failure_reason
    })

def save_result(team_id: str, accuracy: float, f1_score: float, latency_ms: float):
    db = get_db()
    result_ref = db.collection('results').document(team_id)
    result_ref.set({
        'team_id': team_id,
        'accuracy': accuracy,
        'f1_score': f1_score,
        'latency_ms': latency_ms,
        'evaluated_at': firestore.SERVER_TIMESTAMP
    }, merge=True)

def save_predictions(team_id: str, predictions: List[int]):
    db = get_db()
    predictions_ref = db.collection('predictions').document(team_id)
    predictions_ref.set({
        'team_id': team_id,
        'predictions': predictions,
        'saved_at': firestore.SERVER_TIMESTAMP
    }, merge=True)

def get_all_predictions() -> Dict[str, List[int]]:
    db = get_db()
    predictions_docs = db.collection('predictions').stream()
    
    all_predictions = {}
    for doc in predictions_docs:
        data = doc.to_dict()
        all_predictions[data['team_id']] = data['predictions']
    
    return all_predictions

def save_plagiarism_data(team_id: str, plagiarism_cases: List[Dict], is_flagged: bool):
    db = get_db()
    plagiarism_ref = db.collection('plagiarism').document(team_id)
    
    plagiarism_ref.set({
        'team_id': team_id,
        'is_flagged': is_flagged,
        'plagiarism_cases': plagiarism_cases,
        'checked_at': firestore.SERVER_TIMESTAMP
    }, merge=True)

def get_plagiarism_data(team_id: str) -> Optional[Dict]:
    db = get_db()
    doc = db.collection('plagiarism').document(team_id).get()
    
    if doc.exists:
        return doc.to_dict()
    return None

def get_all_plagiarism_flags() -> Dict[str, bool]:
    db = get_db()
    plagiarism_docs = db.collection('plagiarism').stream()
    
    flags = {}
    for doc in plagiarism_docs:
        data = doc.to_dict()
        flags[data['team_id']] = data.get('is_flagged', False)
    
    return flags

def get_leaderboard() -> List[LeaderboardEntry]:
    db = get_db()
    
    results_docs = db.collection('results').stream()
    plagiarism_flags = get_all_plagiarism_flags()
    
    results_list = []
    for doc in results_docs:
        result_data = doc.to_dict()
        team_id = result_data['team_id']
        
        team_doc = db.collection('teams').document(team_id).get()
        if team_doc.exists:
            team_data = team_doc.to_dict()
            
            plagiarism_data = get_plagiarism_data(team_id)
            is_plagiarized = plagiarism_flags.get(team_id, False)
            plagiarism_summary = None
            
            if plagiarism_data and is_plagiarized:
                cases = plagiarism_data.get('plagiarism_cases', [])
                if cases:
                    from app.db.models import PlagiarismSummary
                    plagiarism_summary = PlagiarismSummary(
                        is_flagged=True,
                        similar_teams_count=len(cases),
                        highest_similarity=cases[0]['similarity_score'],
                        similar_teams=[case['team_id'] for case in cases]
                    )
            
            results_list.append({
                'team_id': team_id,
                'team_name': team_data['team_name'],
                'accuracy': result_data.get('accuracy', 0),
                'f1_score': result_data.get('f1_score', 0),
                'latency_ms': result_data.get('latency_ms', 0),
                'evaluated_at': result_data.get('evaluated_at'),
                'is_plagiarized': is_plagiarized,
                'plagiarism_summary': plagiarism_summary
            })
    
    results_list.sort(key=lambda x: (-x['accuracy'], -x['f1_score'], x['latency_ms']))
    
    leaderboard = []
    for rank, result in enumerate(results_list, start=1):
        leaderboard.append(LeaderboardEntry(
            rank=rank,
            team_id=result['team_id'],
            team_name=result['team_name'],
            accuracy=result['accuracy'],
            f1_score=result['f1_score'],
            latency_ms=result['latency_ms'],
            evaluated_at=result['evaluated_at'],
            is_plagiarized=result['is_plagiarized'],
            plagiarism_summary=result['plagiarism_summary']
        ))
    
    return leaderboard

def get_team_result(team_id: str) -> Optional[dict]:
    db = get_db()
    
    team_doc = db.collection('teams').document(team_id).get()
    if not team_doc.exists:
        return None
    
    team_data = team_doc.to_dict()
    
    queue_doc = db.collection('queue').document(team_id).get()
    queue_data = queue_doc.to_dict() if queue_doc.exists else {}
    
    result_doc = db.collection('results').document(team_id).get()
    result_data = result_doc.to_dict() if result_doc.exists else {}
    
    result = {
        "team_id": team_id,
        "team_name": team_data['team_name'],
        "status": queue_data.get('status'),
        "accuracy": result_data.get('accuracy'),
        "f1_score": result_data.get('f1_score'),
        "latency_ms": result_data.get('latency_ms'),
        "evaluated_at": result_data.get('evaluated_at'),
    }
    
    if result["status"] == QueueStatus.COMPLETED.value and result_data:
        leaderboard = get_leaderboard()
        for entry in leaderboard:
            if entry.team_id == team_id:
                result["rank"] = entry.rank
                break
    
    return result

def get_team_endpoint(team_id: str) -> Optional[str]:
    db = get_db()
    doc = db.collection('teams').document(team_id).get()
    
    if doc.exists:
        return doc.to_dict()['endpoint_url']
    return None

def verify_team_owner(team_id: str, user_id: str) -> bool:
    db = get_db()
    doc = db.collection('teams').document(team_id).get()
    
    if doc.exists:
        return doc.to_dict().get('user_id') == user_id
    return False
