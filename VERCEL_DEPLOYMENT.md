# Vercel Deployment Guide - Backend & Frontend

This guide explains how to deploy both the backend (FastAPI) and frontend (Flutter Web) on Vercel.

---

## 🏗️ Architecture

```
┌─────────────────────┐         ┌──────────────────────┐         ┌─────────────────┐
│  Flutter Web App    │ HTTPS   │  Backend API         │  Auth   │   Firebase      │
│  (Vercel)           │ ──────> │  (Vercel Serverless) │ ──────> │  (Firestore)    │
│  frontend.vercel.app│         │  backend.vercel.app  │         │                 │
└─────────────────────┘         └──────────────────────┘         └─────────────────┘
```

---

## 📋 Prerequisites

- GitHub account
- Vercel account (sign up at [vercel.com](https://vercel.com))
- Firebase project with Firestore enabled
- Git repository with your code

---

## 🚀 Part 1: Deploy Backend to Vercel

### Step 1: Prepare Backend for Vercel

Your backend is already configured for Vercel serverless deployment with:
- `backend/vercel.json` - Vercel configuration
- `backend/app/api/process.py` - Manual queue processing endpoint
- `backend/app/main.py` - Serverless-compatible main app

### Step 2: Push Code to GitHub

```bash
cd /Users/sarathyv/portal
git add .
git commit -m "Configure for Vercel deployment"
git push origin main
```

### Step 3: Deploy Backend on Vercel

1. **Go to [vercel.com](https://vercel.com)** and sign in with GitHub

2. **Click "Add New Project"**

3. **Import your repository**
   - Select your `portal` repository
   - Click "Import"

4. **Configure Backend Project**:
   - **Project Name**: `portal-backend` (or your preferred name)
   - **Framework Preset**: Other
   - **Root Directory**: `backend`
   - **Build Command**: Leave empty
   - **Output Directory**: Leave empty
   - **Install Command**: `pip install -r requirements.txt`

5. **Add Environment Variables**:
   
   Click "Environment Variables" and add:
   
   - **FIREBASE_CREDENTIALS_JSON**
     ```
     Paste your entire Firebase credentials JSON (from backend/.env)
     ```
   
   - **SECRET_KEY**
     ```
     Generate a strong secret key (e.g., use: openssl rand -hex 32)
     ```
   
   - **ALLOWED_ORIGINS**
     ```
     *
     ```
     (You'll update this after frontend deployment)

6. **Click "Deploy"**

7. **Wait for deployment** (2-3 minutes)

8. **Copy your backend URL**: `https://your-backend.vercel.app`

9. **Test backend**:
   ```bash
   curl https://your-backend.vercel.app/health
   ```

---

## 🌐 Part 2: Deploy Frontend to Vercel

### Step 1: Deploy Frontend on Vercel

1. **Go back to Vercel Dashboard**

2. **Click "Add New Project"**

3. **Import the SAME repository again**
   - Select your `portal` repository
   - Click "Import"

4. **Configure Frontend Project**:
   - **Project Name**: `portal-frontend` (or your preferred name)
   - **Framework Preset**: Other
   - **Root Directory**: `frontend`
   - **Build Command**: Leave empty (uses vercel.json)
   - **Output Directory**: Leave empty (uses vercel.json)
   - **Install Command**: Leave empty (uses vercel.json)

5. **Add Environment Variables**:
   
   Click "Environment Variables" and add:
   
   - **BACKEND_URL**
     ```
     https://your-backend.vercel.app
     ```
     (Use the backend URL from Part 1, Step 8)

6. **Click "Deploy"**

7. **Wait for deployment** (5-10 minutes - Flutter build takes time)

8. **Copy your frontend URL**: `https://your-frontend.vercel.app`

---

## 🔧 Part 3: Update Backend CORS

Now that you have your frontend URL, update the backend to allow requests from it.

1. **Go to Vercel Dashboard → Backend Project**

2. **Go to Settings → Environment Variables**

3. **Edit ALLOWED_ORIGINS**:
   ```
   https://your-frontend.vercel.app,http://localhost:*,http://127.0.0.1:*
   ```
   (Replace with your actual frontend URL)

4. **Redeploy Backend**:
   - Go to "Deployments" tab
   - Click "..." on the latest deployment
   - Click "Redeploy"

---

## ⚙️ Part 4: Configure Queue Processing

Since Vercel uses serverless functions, there's no background worker. You need to trigger queue processing manually.

### Option A: Manual Trigger (For Testing)

After a team submits an endpoint, call:
```bash
curl -X POST https://your-backend.vercel.app/process-queue
```

### Option B: Vercel Cron Jobs (Recommended)

1. **Create `backend/vercel.json`** and add cron configuration:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "app/main.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "app/main.py"
    }
  ],
  "env": {
    "FIREBASE_CREDENTIALS_JSON": "@firebase_credentials_json",
    "SECRET_KEY": "@secret_key",
    "ALLOWED_ORIGINS": "@allowed_origins"
  },
  "crons": [
    {
      "path": "/process-queue",
      "schedule": "*/5 * * * *"
    }
  ]
}
```

This will trigger queue processing every 5 minutes automatically.

2. **Redeploy backend** for cron to take effect.

### Option C: Frontend Auto-Trigger

Modify the submit endpoint to automatically trigger processing after submission.

---

## ✅ Verification Checklist

### Backend
- [ ] Backend deployed: `https://your-backend.vercel.app`
- [ ] Health check works: `curl https://your-backend.vercel.app/health`
- [ ] Environment variables set (Firebase, SECRET_KEY, ALLOWED_ORIGINS)
- [ ] CORS configured with frontend URL
- [ ] Queue processing endpoint works: `curl -X POST https://your-backend.vercel.app/process-queue`

### Frontend
- [ ] Frontend deployed: `https://your-frontend.vercel.app`
- [ ] Environment variable BACKEND_URL set
- [ ] App loads without errors
- [ ] Can login with Firebase
- [ ] Can submit endpoints
- [ ] Leaderboard loads

---

## 🔍 Troubleshooting

### Backend Issues

**Deployment fails:**
- Check build logs in Vercel dashboard
- Verify `requirements.txt` has all dependencies
- Check Python version compatibility

**Firebase authentication errors:**
- Verify FIREBASE_CREDENTIALS_JSON is correctly set
- Check Firebase project ID matches
- Ensure Firestore is enabled in Firebase console

**CORS errors:**
- Update ALLOWED_ORIGINS with frontend URL
- Redeploy backend after changing environment variables
- Clear browser cache

### Frontend Issues

**Build fails:**
- Check Flutter version compatibility
- Verify `pubspec.yaml` dependencies
- Check build logs in Vercel dashboard

**API connection failed:**
- Verify BACKEND_URL environment variable
- Check backend is accessible
- Check browser console for errors

**White screen or loading forever:**
- Check browser console for JavaScript errors
- Verify Firebase configuration in `firebase_options.dart`
- Check network tab for failed requests

---

## 🔐 Security Best Practices

- [ ] Use strong SECRET_KEY (generate with `openssl rand -hex 32`)
- [ ] Restrict ALLOWED_ORIGINS to your frontend domain only
- [ ] Never commit `.env` file to Git
- [ ] Use Vercel environment variables for secrets
- [ ] Enable Firebase security rules
- [ ] Regularly update dependencies

---

## 📊 Monitoring

### View Logs

**Backend Logs:**
1. Go to Vercel Dashboard → Backend Project
2. Click "Deployments"
3. Click on a deployment
4. Click "Functions" tab to see logs

**Frontend Logs:**
1. Go to Vercel Dashboard → Frontend Project
2. Click "Deployments"
3. Click on a deployment
4. Check build logs

### Check Queue Processing

```bash
curl https://your-backend.vercel.app/process-queue-status
```

---

## 🔄 Updates and Redeployment

### Update Backend Code

1. Make changes to backend code
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend"
   git push origin main
   ```
3. Vercel will automatically redeploy

### Update Frontend Code

1. Make changes to frontend code
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Update frontend"
   git push origin main
   ```
3. Vercel will automatically redeploy

### Manual Redeploy

If auto-deploy doesn't work:
1. Go to Vercel Dashboard
2. Select your project
3. Go to "Deployments" tab
4. Click "..." on latest deployment
5. Click "Redeploy"

---

## 🎯 Important Notes for Serverless Deployment

### Queue Processing
- Vercel serverless functions have a **10-second timeout** on Hobby plan
- Vercel serverless functions have a **60-second timeout** on Pro plan
- For long-running evaluations, consider:
  - Breaking evaluation into smaller chunks
  - Using Vercel Cron Jobs (every 5 minutes)
  - Upgrading to Vercel Pro for longer timeouts

### Cold Starts
- First request after inactivity may be slow (cold start)
- Subsequent requests will be faster
- Consider using Vercel Cron Jobs to keep functions warm

### Data Persistence
- No local file storage in serverless
- All data must be in Firebase Firestore
- Test data (X_test.csv, y_true.csv) must be loaded from Firebase or external storage

---

## 📞 Support

For issues:
1. Check Vercel deployment logs
2. Check browser console for frontend errors
3. Verify environment variables are set correctly
4. Test API endpoints with curl
5. Check Firebase console for errors

---

## 🎉 Success!

Your ML Hackathon Platform is now live on Vercel:
- **Frontend**: https://your-frontend.vercel.app
- **Backend**: https://your-backend.vercel.app
- **Health Check**: https://your-backend.vercel.app/health

Participants can now:
1. Sign up and login with Firebase
2. Submit their ML model endpoints
3. Get evaluated on fraud detection test cases
4. See results on the leaderboard

---

## 🔗 Useful Links

- [Vercel Documentation](https://vercel.com/docs)
- [Vercel Python Runtime](https://vercel.com/docs/runtimes#official-runtimes/python)
- [Vercel Cron Jobs](https://vercel.com/docs/cron-jobs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
