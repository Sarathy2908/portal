import numpy as np
from typing import List, Dict, Tuple, Optional
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime

class PlagiarismDetector:
    def __init__(self, similarity_threshold: float = 0.95):
        self.similarity_threshold = similarity_threshold
    
    def calculate_similarity(self, predictions1: List[int], predictions2: List[int]) -> float:
        if len(predictions1) != len(predictions2):
            return 0.0
        
        exact_match_ratio = sum(p1 == p2 for p1, p2 in zip(predictions1, predictions2)) / len(predictions1)
        
        pred1_array = np.array(predictions1).reshape(1, -1)
        pred2_array = np.array(predictions2).reshape(1, -1)
        
        cosine_sim = cosine_similarity(pred1_array, pred2_array)[0][0]
        
        hamming_distance = sum(p1 != p2 for p1, p2 in zip(predictions1, predictions2))
        hamming_similarity = 1 - (hamming_distance / len(predictions1))
        
        combined_similarity = (exact_match_ratio * 0.5) + (cosine_sim * 0.3) + (hamming_similarity * 0.2)
        
        return float(combined_similarity)
    
    def detect_plagiarism(
        self, 
        team_id: str, 
        predictions: List[int], 
        all_team_predictions: Dict[str, List[int]]
    ) -> List[Dict[str, any]]:
        plagiarism_cases = []
        
        for other_team_id, other_predictions in all_team_predictions.items():
            if other_team_id == team_id:
                continue
            
            similarity = self.calculate_similarity(predictions, other_predictions)
            
            if similarity >= self.similarity_threshold:
                plagiarism_cases.append({
                    'team_id': other_team_id,
                    'similarity_score': similarity,
                    'detected_at': datetime.utcnow()
                })
        
        plagiarism_cases.sort(key=lambda x: x['similarity_score'], reverse=True)
        
        return plagiarism_cases
    
    def is_plagiarized(self, plagiarism_cases: List[Dict]) -> bool:
        return len(plagiarism_cases) > 0
    
    def get_plagiarism_summary(self, plagiarism_cases: List[Dict]) -> Optional[Dict]:
        if not plagiarism_cases:
            return None
        
        return {
            'is_flagged': True,
            'similar_teams_count': len(plagiarism_cases),
            'highest_similarity': plagiarism_cases[0]['similarity_score'],
            'similar_teams': [case['team_id'] for case in plagiarism_cases]
        }
