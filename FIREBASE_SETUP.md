# Firebase Setup Guide

This guide will help you configure Firebase for the ML Hackathon Platform with email/password authentication and Firestore database.

## Prerequisites

- Firebase account (free tier is sufficient)
- Firebase CLI installed: `npm install -g firebase-tools`
- FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "ml-hackathon-platform")
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Email/Password**
3. Enable **Email/Password** authentication
4. Click **Save**

## Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose a location closest to your users
5. Click **Enable**

### Firestore Security Rules (Production)

Replace test mode rules with these for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Teams collection - users can only write their own teams
    match /teams/{teamId} {
      allow read: if true;
      allow write: if request.auth != null && request.resource.data.user_id == request.auth.uid;
    }
    
    // Queue collection - read only for users, write only for backend
    match /queue/{teamId} {
      allow read: if true;
      allow write: if false; // Only backend can write
    }
    
    // Results collection - read only
    match /results/{teamId} {
      allow read: if true;
      allow write: if false; // Only backend can write
    }
  }
}
```

## Step 4: Get Firebase Service Account Key (Backend)

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Go to **Service accounts** tab
3. Click **Generate new private key**
4. Save the JSON file as `firebase-credentials.json`
5. Move it to: `/Users/sarathyv/portal/backend/app/data/firebase-credentials.json`

**IMPORTANT**: Add this to `.gitignore`:
```
backend/app/data/firebase-credentials.json
```

## Step 5: Configure Flutter Frontend

### Option A: Automatic Configuration (Recommended)

Run FlutterFire CLI from the frontend directory:

```bash
cd /Users/sarathyv/portal/frontend
flutterfire configure --project=YOUR_PROJECT_ID
```

This will:
- Create/update `firebase_options.dart` with your project configuration
- Register your app with Firebase
- Download configuration files

### Option B: Manual Configuration

1. In Firebase Console, go to **Project Settings**
2. Scroll down to "Your apps"
3. Click the **Web** icon (</>)
4. Register your app with a nickname
5. Copy the Firebase configuration object
6. Update `/Users/sarathyv/portal/frontend/lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

## Step 6: Install Dependencies

### Backend

```bash
cd /Users/sarathyv/portal/backend
source venv/bin/activate
pip install -r requirements.txt
```

### Frontend

```bash
cd /Users/sarathyv/portal/frontend
flutter pub get
```

## Step 7: Environment Variables (Optional)

Create `.env` file in backend directory:

```bash
SECRET_KEY=your-super-secret-key-change-this-in-production
FIREBASE_PROJECT_ID=your-project-id
```

Update `backend/app/config.py` to use environment variables.

## Step 8: Test the Setup

### Start Backend

```bash
cd /Users/sarathyv/portal/backend
source venv/bin/activate
uvicorn app.main:app --reload
```

### Start Frontend

```bash
cd /Users/sarathyv/portal/frontend
flutter run -d chrome
```

### Test Authentication

1. Open the app in Chrome
2. Click "Sign Up"
3. Create an account with email/password
4. You should be redirected to the main screen
5. Check Firebase Console → Authentication to see the new user

## Step 9: Verify Firestore Collections

After submitting an endpoint, check Firestore Console for these collections:

- **teams**: Contains team information
  - `team_id` (string)
  - `team_name` (string)
  - `endpoint_url` (string)
  - `user_id` (string)
  - `created_at` (timestamp)

- **queue**: Contains queue entries
  - `team_id` (string)
  - `status` (string): QUEUED, EVALUATING, COMPLETED, FAILED
  - `position` (number)
  - `queued_at` (timestamp)
  - `failure_reason` (string, optional)

- **results**: Contains evaluation results
  - `team_id` (string)
  - `accuracy` (number)
  - `f1_score` (number)
  - `latency_ms` (number)
  - `evaluated_at` (timestamp)

## Troubleshooting

### Backend Issues

**Error: "Could not find Firebase credentials"**
- Ensure `firebase-credentials.json` is in `backend/app/data/`
- Check file permissions

**Error: "Firebase app already initialized"**
- This is normal on hot reload
- Restart the backend server

### Frontend Issues

**Error: "Firebase not initialized"**
- Run `flutterfire configure` again
- Check `firebase_options.dart` has correct values

**Error: "Authentication failed"**
- Verify Email/Password is enabled in Firebase Console
- Check network connectivity
- Look at browser console for detailed errors

### Firestore Permission Denied

- Check Firestore Security Rules
- Ensure user is authenticated
- Verify auth token is being sent in API requests

## Production Deployment

### Backend (Render/Heroku)

1. Add `firebase-credentials.json` as environment variable:
   ```bash
   # Convert to base64
   base64 firebase-credentials.json
   
   # Set as environment variable
   FIREBASE_CREDENTIALS_BASE64=<base64-string>
   ```

2. Update `backend/app/db/firebase_service.py` to decode from env:
   ```python
   import os
   import base64
   import json
   
   if os.getenv('FIREBASE_CREDENTIALS_BASE64'):
       cred_json = base64.b64decode(os.getenv('FIREBASE_CREDENTIALS_BASE64'))
       cred_dict = json.loads(cred_json)
       cred = credentials.Certificate(cred_dict)
   ```

### Frontend (Firebase Hosting)

```bash
cd frontend
flutter build web --release
firebase init hosting
firebase deploy
```

## Security Best Practices

1. **Never commit** `firebase-credentials.json` to version control
2. **Use environment variables** for sensitive data in production
3. **Enable Firestore Security Rules** before going live
4. **Rotate service account keys** periodically
5. **Use HTTPS** for all API endpoints
6. **Implement rate limiting** on authentication endpoints
7. **Enable Firebase App Check** for production

## Cost Considerations

Firebase Free Tier (Spark Plan) includes:
- **Authentication**: 10K verifications/month
- **Firestore**: 1GB storage, 50K reads/day, 20K writes/day
- **Hosting**: 10GB storage, 360MB/day transfer

This is sufficient for hackathons with up to 100 teams.

## Support

For issues:
1. Check Firebase Console → Usage tab
2. Review Firestore logs
3. Check browser console for frontend errors
4. Review backend logs for API errors

---

**Your Firebase project is now configured!** 🎉

Users can now:
- ✅ Sign up with email/password
- ✅ Sign in securely
- ✅ Submit ML endpoints (authenticated)
- ✅ View leaderboard (public)
- ✅ Track queue status (public)
