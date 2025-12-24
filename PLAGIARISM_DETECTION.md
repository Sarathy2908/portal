# Plagiarism Detection System

## Overview
Implemented prediction-based plagiarism detection system that automatically checks for similar model outputs when teams submit their ML endpoints.

## How It Works

### Detection Algorithm
- **Similarity Metrics**: Combines three approaches:
  - Exact match ratio (50% weight)
  - Cosine similarity (30% weight)
  - Hamming similarity (20% weight)
- **Threshold**: 95% similarity triggers plagiarism flag
- **Comparison**: Each submission is compared against all previous submissions

### Backend Implementation

#### New Files
1. **`backend/app/core/plagiarism_detector.py`**
   - `PlagiarismDetector` class with configurable threshold
   - `calculate_similarity()`: Multi-metric similarity calculation
   - `detect_plagiarism()`: Compares predictions against all teams
   - `is_plagiarized()`: Boolean check for flagging
   - `get_plagiarism_summary()`: Summary statistics

2. **`backend/app/api/plagiarism.py`**
   - `GET /plagiarism/{team_id}`: Get plagiarism data for specific team
   - `GET /plagiarism-summary`: Overall plagiarism statistics

#### Modified Files
1. **`backend/app/db/models.py`**
   - Added `PlagiarismCase` model
   - Added `PlagiarismSummary` model
   - Updated `LeaderboardEntry` with `is_plagiarized` and `plagiarism_summary` fields

2. **`backend/app/db/firebase_service.py`**
   - `save_predictions()`: Store team predictions
   - `get_all_predictions()`: Retrieve all predictions for comparison
   - `save_plagiarism_data()`: Store plagiarism detection results
   - `get_plagiarism_data()`: Retrieve plagiarism data for a team
   - `get_all_plagiarism_flags()`: Get all plagiarism flags
   - Updated `get_leaderboard()`: Include plagiarism data in response

3. **`backend/app/core/evaluator.py`**
   - Updated `evaluate_team()` to return predictions list

4. **`backend/app/core/queue_manager.py`**
   - Integrated plagiarism detection into evaluation pipeline
   - Saves predictions after successful evaluation
   - Runs plagiarism check against all existing predictions
   - Stores plagiarism results in Firebase

5. **`backend/app/main.py`**
   - Added plagiarism router to API

### Frontend Implementation

#### Modified Files
1. **`frontend/lib/models/leaderboard.dart`**
   - Added `PlagiarismSummary` class
   - Updated `LeaderboardEntry` with plagiarism fields

2. **`frontend/lib/widgets/leaderboard_table.dart`**
   - **Animations**:
     - Staggered entry animations with scale and fade effects
     - Rotating trophy icons for top 3 teams
     - Pulsing plagiarism badges
   - **Visual Enhancements**:
     - Gradient background on card
     - Color-coded metric cells (green/blue/orange/red)
     - Hover effects on rows
     - Plagiarized teams highlighted in red
   - **Plagiarism Indicators**:
     - "FLAGGED" status badge with warning icon
     - Animated plagiarism badge next to team name
     - Tooltip showing similarity details
     - "CLEAN" status badge for non-plagiarized teams

3. **`frontend/lib/screens/leaderboard_screen.dart`**
   - **Animated Header**:
     - Typewriter animation for title
     - Fade-in and slide-up effect
   - **Statistics Cards**:
     - Total teams count
     - Clean teams count (green)
     - Flagged teams count (red)
     - Scale-in animation
   - **Plagiarism Warning Banner**:
     - Pulsing red banner when plagiarism detected
     - Shows count of flagged teams
     - Animated color transitions

4. **`frontend/pubspec.yaml`**
   - Added `animated_text_kit: ^4.2.2` for text animations

## Firebase Collections

### New Collections
1. **`predictions`**
   ```
   {
     team_id: string,
     predictions: array<int>,
     saved_at: timestamp
   }
   ```

2. **`plagiarism`**
   ```
   {
     team_id: string,
     is_flagged: boolean,
     plagiarism_cases: array<{
       team_id: string,
       similarity_score: float,
       detected_at: string
     }>,
     checked_at: timestamp
   }
   ```

## API Endpoints

### New Endpoints
- `GET /plagiarism/{team_id}`: Get plagiarism details for a team
- `GET /plagiarism-summary`: Get overall plagiarism statistics

### Updated Endpoints
- `GET /leaderboard`: Now includes `is_plagiarized` and `plagiarism_summary` fields

## UI Features

### Leaderboard Enhancements
1. **Animations**:
   - Typewriter effect on title
   - Staggered row animations
   - Rotating trophy icons
   - Pulsing plagiarism badges
   - Smooth transitions

2. **Visual Indicators**:
   - Red background for plagiarized teams
   - Green "CLEAN" badges
   - Red "FLAGGED" badges with warning icons
   - Animated plagiarism icon next to team name
   - Color-coded performance metrics

3. **Statistics Dashboard**:
   - Total teams
   - Clean submissions
   - Flagged submissions
   - Animated cards with icons

4. **Warning Banner**:
   - Appears when plagiarism detected
   - Pulsing animation
   - Shows count and description

## Configuration

### Similarity Threshold
Default: 95% (configurable in `backend/app/core/queue_manager.py`)

```python
plagiarism_detector = PlagiarismDetector(similarity_threshold=0.95)
```

### Adjusting Threshold
- Lower threshold (e.g., 0.90): More sensitive, may flag more teams
- Higher threshold (e.g., 0.98): Less sensitive, only exact matches

## Testing

### Backend Testing
```bash
cd backend
# Start the server
uvicorn app.main:app --reload

# Test plagiarism endpoints
curl http://localhost:8000/plagiarism-summary
curl http://localhost:8000/plagiarism/{team_id}
```

### Frontend Testing
```bash
cd frontend
# Install new dependency
flutter pub get

# Run the app
flutter run -d chrome
```

## Deployment Notes

### Backend
- No additional environment variables needed
- Plagiarism detection runs automatically during evaluation
- Works with both traditional server and serverless (Vercel) deployments

### Frontend
- Run `flutter pub get` to install `animated_text_kit`
- No configuration changes needed
- Animations work on all platforms (web, mobile)

## Future Enhancements

1. **Admin Dashboard**: View all plagiarism cases with detailed comparisons
2. **Notification System**: Alert admins when plagiarism detected
3. **Appeal Process**: Allow teams to dispute plagiarism flags
4. **Code Similarity**: If teams submit code, add code-based plagiarism detection
5. **Temporal Analysis**: Track when similar submissions occurred
6. **Confidence Scores**: Show prediction confidence if available from endpoints
