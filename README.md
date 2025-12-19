# 🏆 ML Hackathon Evaluation Platform

A complete, production-ready platform for evaluating ML model endpoints in a fair, queue-based system with real-time leaderboard.

## 🎯 Overview

This platform allows hackathon participants to submit their ML model endpoints for evaluation. The system:
- ✅ Evaluates one team at a time (FIFO queue)
- ✅ Calculates accuracy, F1 score, and latency
- ✅ Displays live leaderboard with rankings
- ✅ Provides real-time status updates
- ✅ Uses 100% free stack (FastAPI + Flutter + SQLite)

## 📁 Project Structure

```
portal/
├── backend/                    # FastAPI Backend
│   ├── app/
│   │   ├── main.py            # API entry point
│   │   ├── api/               # API endpoints
│   │   ├── core/              # Business logic
│   │   ├── db/                # Database layer
│   │   ├── utils/             # Utilities
│   │   └── data/              # Test data & DB
│   ├── requirements.txt
│   ├── Dockerfile
│   └── README.md
├── frontend/                   # Flutter Web Frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/           # UI screens
│   │   ├── providers/         # State management
│   │   ├── models/            # Data models
│   │   ├── widgets/           # Reusable widgets
│   │   └── core/              # API & constants
│   ├── pubspec.yaml
│   └── README.md
├── docker-compose.yml          # Docker orchestration
└── README.md                   # This file
```

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Clone the repository
cd portal

# Start both backend and frontend
docker-compose up -d

# Backend will be available at http://localhost:8000
# Access API docs at http://localhost:8000/docs
```

### Option 2: Manual Setup

**Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Frontend:**
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## 📊 System Flow

```
1. Team submits endpoint → 2. Validation → 3. Queue entry
                                              ↓
6. Leaderboard update ← 5. Results saved ← 4. Evaluation
```

### Detailed Flow:

1. **Submission**: Team submits ML endpoint via web interface
2. **Validation**: System checks if endpoint is reachable
3. **Queue**: Team added to FIFO queue with position
4. **Evaluation**: Background worker:
   - Sends test data to team endpoint
   - Receives predictions
   - Calculates metrics (accuracy, F1, latency)
5. **Storage**: Results saved to database
6. **Leaderboard**: Rankings updated automatically

## 🎮 Usage Guide

### For Participants

1. **Prepare Your ML Endpoint**
   - Must accept POST requests with JSON
   - Must return predictions in correct format
   - Must respond within 5 seconds

2. **Submit Endpoint**
   - Open the web interface
   - Enter Team ID, Team Name, and Endpoint URL
   - Click "Submit Endpoint"

3. **Monitor Status**
   - View queue position
   - See evaluation status (Queued/Evaluating/Completed)
   - Get estimated wait time

4. **Check Leaderboard**
   - View your rank
   - Compare with other teams
   - See detailed metrics

### For Organizers

1. **Setup Platform**
   ```bash
   docker-compose up -d
   ```

2. **Prepare Test Data**
   - Replace `backend/app/data/X_test.csv` with your features
   - Replace `backend/app/data/y_true.csv` with true labels

3. **Configure Settings**
   - Edit `backend/app/config.py` for timeouts and intervals
   - Edit `frontend/lib/core/constants.dart` for API URL

4. **Monitor System**
   ```bash
   docker-compose logs -f backend
   ```

## 📝 API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/submit-endpoint` | Submit ML endpoint |
| GET | `/queue-status/{team_id}` | Get queue status |
| GET | `/leaderboard` | Get rankings |
| GET | `/team-result/{team_id}` | Get team results |
| GET | `/health` | Health check |

**Interactive API Docs**: http://localhost:8000/docs

## 🔧 Team Endpoint Specification

Your ML model endpoint must follow this contract:

### Request Format
```json
POST /predict
Content-Type: application/json

{
  "inputs": [
    {"feature_0": 0.5, "feature_1": 0.7, "feature_2": 0.3, ...},
    {"feature_0": 0.2, "feature_1": 0.9, "feature_2": 0.1, ...}
  ]
}
```

### Response Format
```json
{
  "predictions": [1, 0, 1, 1, 0]
}
```

### Requirements
- ✅ Accept POST requests
- ✅ Return JSON with "predictions" array
- ✅ Predictions must match input length
- ✅ Respond within 5 seconds
- ✅ Use HTTP or HTTPS

## 💡 Example Team Endpoint

### Flask Example
```python
from flask import Flask, request, jsonify
import joblib

app = Flask(__name__)
model = joblib.load('model.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    inputs = data['inputs']
    
    # Convert to DataFrame or array
    import pandas as pd
    df = pd.DataFrame(inputs)
    
    # Make predictions
    predictions = model.predict(df).tolist()
    
    return jsonify({'predictions': predictions})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### FastAPI Example
```python
from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()
model = joblib.load('model.pkl')

class PredictionRequest(BaseModel):
    inputs: list

@app.post('/predict')
def predict(request: PredictionRequest):
    import pandas as pd
    df = pd.DataFrame(request.inputs)
    predictions = model.predict(df).tolist()
    return {'predictions': predictions}
```

## 🧪 Testing

### Test Backend
```bash
cd backend
pytest
```

### Test with Dummy Endpoint
```bash
# Terminal 1: Start dummy endpoint
python examples/dummy_endpoint.py

# Terminal 2: Submit to platform
curl -X POST http://localhost:8000/submit-endpoint \
  -H "Content-Type: application/json" \
  -d '{
    "team_id": "test_001",
    "team_name": "Test Team",
    "endpoint_url": "http://localhost:5001/predict"
  }'
```

## 🏅 Ranking System

Teams are ranked by:
1. **Accuracy** (Primary) - Higher is better
2. **F1 Score** (Secondary) - Higher is better  
3. **Evaluation Time** (Tiebreaker) - Earlier is better

## 🔒 Security Features

- ✅ Endpoint validation before queuing
- ✅ Request timeouts (5 seconds)
- ✅ Retry mechanism (1 retry)
- ✅ CORS enabled for web access
- ✅ Input validation on all endpoints
- ✅ SQL injection prevention (parameterized queries)

## 📈 Scaling Considerations

### Current Setup (Hackathon Ready)
- SQLite database (single file)
- Single worker process
- Sequential evaluation

### Production Scaling
- Replace SQLite with PostgreSQL
- Add Redis for queue management
- Multiple worker processes
- Load balancer for API
- Separate evaluation service

## 🐛 Troubleshooting

### Backend Issues

**Database locked error:**
```bash
# Stop all processes
docker-compose down
# Remove database
rm backend/app/data/hackathon.db
# Restart
docker-compose up -d
```

**Queue stuck:**
```bash
# Check logs
docker-compose logs backend
# Reset queue status in database
```

### Frontend Issues

**CORS errors:**
- Ensure backend CORS is enabled (already configured)
- Check API URL in `frontend/lib/core/constants.dart`

**Build errors:**
```bash
cd frontend
flutter clean
flutter pub get
flutter build web
```

## 📦 Deployment

### Backend Deployment (Render)

1. Create `render.yaml`:
```yaml
services:
  - type: web
    name: ml-hackathon-backend
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

2. Push to GitHub
3. Connect to Render
4. Deploy

### Frontend Deployment (Firebase)

```bash
cd frontend
flutter build web --release
firebase init hosting
firebase deploy
```

### Frontend Deployment (Netlify)

```bash
cd frontend
flutter build web --release
netlify deploy --dir=build/web --prod
```

## 🛠️ Configuration

### Backend Config (`backend/app/config.py`)
```python
EVALUATION_TIMEOUT = 5          # Seconds
MAX_RETRIES = 1                 # Retry attempts
QUEUE_CHECK_INTERVAL = 5        # Queue polling interval
```

### Frontend Config (`frontend/lib/core/constants.dart`)
```dart
static const String apiBaseUrl = 'http://localhost:8000';
static const int pollInterval = 5;  // Seconds
```

## 📚 Technology Stack

### Backend
- **FastAPI** - Modern Python web framework
- **SQLite** - Lightweight database
- **Uvicorn** - ASGI server
- **Pandas** - Data manipulation
- **Scikit-learn** - Metrics calculation
- **HTTPx** - Async HTTP client

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - API client
- **Material Design** - UI components

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

MIT License - Free for commercial and non-commercial use

## 🎓 Educational Use

This platform is perfect for:
- ML hackathons
- Kaggle-style competitions
- University ML courses
- Corporate ML challenges
- Training workshops

## 📞 Support

For issues and questions:
- Check the READMEs in `backend/` and `frontend/`
- Review API documentation at `/docs`
- Check troubleshooting section above

## 🌟 Features Roadmap

- [ ] User authentication
- [ ] Multiple datasets support
- [ ] Custom metrics configuration
- [ ] Team management dashboard
- [ ] Email notifications
- [ ] Submission history
- [ ] Model versioning
- [ ] A/B testing support

## ✅ Hackathon Checklist

- [x] Backend API with queue system
- [x] Database schema and operations
- [x] Evaluation engine with metrics
- [x] Background worker
- [x] Flutter web frontend
- [x] Real-time status updates
- [x] Live leaderboard
- [x] Docker configuration
- [x] Comprehensive documentation
- [x] Example endpoints
- [x] Testing utilities

---

## 🚀 Deployment

### Quick Deploy: Intel Server + Vercel

**Backend (Intel Server):**
```bash
cd backend
./setup_env.sh  # Setup Firebase credentials
./deploy.sh production
```

**Frontend (Vercel):**
1. Push to GitHub
2. Import to Vercel
3. Set environment variable: `API_BASE_URL=http://your-server-ip:8000`
4. Deploy

📖 **Full Guide:** See [QUICK_DEPLOY.md](QUICK_DEPLOY.md) and [DEPLOYMENT.md](DEPLOYMENT.md)

---

**Built for ML Hackathons** | **100% Free Stack** | **Production Ready**
