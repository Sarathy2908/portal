# Quick Start: Firebase Migration

## What Changed?

The platform now uses **Firebase** instead of SQLite:
- ✅ **Firebase Authentication** - Email/password login
- ✅ **Cloud Firestore** - Real-time database
- ✅ **Secure** - User-based access control
- ✅ **Scalable** - Cloud-based infrastructure

## Quick Setup (5 minutes)

### 1. Get Firebase Credentials

```bash
# You already logged in to Firebase
# Now configure your project
cd /Users/sarathyv/portal/frontend
flutterfire configure --project=YOUR_PROJECT_ID
```

This creates `firebase_options.dart` with your project config.

### 2. Get Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click ⚙️ **Project Settings** → **Service accounts**
4. Click **Generate new private key**
5. Save as: `/Users/sarathyv/portal/backend/app/data/firebase-credentials.json`

### 3. Enable Firebase Services

In Firebase Console:

**Authentication:**
- Go to **Authentication** → **Sign-in method**
- Enable **Email/Password**

**Firestore:**
- Go to **Firestore Database**
- Click **Create database**
- Choose **Test mode** (for now)
- Select your region

### 4. Install Dependencies

**Backend:**
```bash
cd /Users/sarathyv/portal/backend
source venv/bin/activate
pip install -r requirements.txt
```

**Frontend:**
```bash
cd /Users/sarathyv/portal/frontend
flutter pub get
```

### 5. Start the Platform

**Terminal 1 - Backend:**
```bash
cd /Users/sarathyv/portal/backend
source venv/bin/activate
uvicorn app.main:app --reload
```

**Terminal 2 - Frontend:**
```bash
cd /Users/sarathyv/portal/frontend
flutter run -d chrome
```

**Terminal 3 - Dummy Endpoint (for testing):**
```bash
cd /Users/sarathyv/portal/examples
source venv/bin/activate
python dummy_endpoint.py
```

## First Time Usage

1. **Sign Up**: Create account with email/password
2. **Sign In**: Login with your credentials
3. **Submit Endpoint**: Enter team details and ML endpoint URL
4. **Watch Queue**: See your position in queue
5. **View Leaderboard**: Check rankings after evaluation

## API Changes

### New Endpoints

- `POST /auth/register` - Create new account
- `POST /auth/login` - Sign in
- `GET /auth/me` - Get current user

### Updated Endpoints

All submission endpoints now require authentication:
- Add `Authorization: Bearer <token>` header
- Token obtained from login/register

### Example API Call

```bash
# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'

# Response: {"access_token": "eyJ...", "uid": "...", "email": "..."}

# Submit endpoint (with auth)
curl -X POST http://localhost:8000/submit-endpoint \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ..." \
  -d '{
    "team_id": "team_001",
    "team_name": "My Team",
    "endpoint_url": "http://localhost:5001/predict"
  }'
```

## Firestore Collections

Your data is stored in these collections:

### teams
```json
{
  "team_id": "team_001",
  "team_name": "My Team",
  "endpoint_url": "http://...",
  "user_id": "firebase_uid",
  "created_at": "timestamp"
}
```

### queue
```json
{
  "team_id": "team_001",
  "status": "QUEUED",
  "position": 1,
  "queued_at": "timestamp",
  "failure_reason": null
}
```

### results
```json
{
  "team_id": "team_001",
  "accuracy": 0.85,
  "f1_score": 0.82,
  "latency_ms": 45.2,
  "evaluated_at": "timestamp"
}
```

## Troubleshooting

### "Firebase credentials not found"
```bash
# Make sure file exists
ls backend/app/data/firebase-credentials.json

# If not, download from Firebase Console
```

### "Authentication failed"
- Check Email/Password is enabled in Firebase Console
- Verify email format is correct
- Password must be at least 6 characters

### "Permission denied" in Firestore
- Go to Firestore → Rules
- For testing, use:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## What's Different?

### Before (SQLite)
- ❌ No authentication
- ❌ Local database file
- ❌ Anyone could submit
- ❌ Data lost on server restart

### After (Firebase)
- ✅ Secure email/password auth
- ✅ Cloud database
- ✅ User-owned submissions
- ✅ Persistent data
- ✅ Real-time updates
- ✅ Scalable infrastructure

## Next Steps

1. **Test locally** - Create account and submit endpoint
2. **Review Firestore** - Check data in Firebase Console
3. **Update security rules** - Before production
4. **Deploy** - Use Firebase Hosting for frontend

---

**Need help?** Check `FIREBASE_SETUP.md` for detailed instructions.
