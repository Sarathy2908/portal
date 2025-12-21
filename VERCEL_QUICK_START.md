# Quick Start: Deploy to Vercel (Both Backend & Frontend)

This is a simplified guide to deploy both backend and frontend to Vercel in under 10 minutes.

---

## 🚀 Quick Deployment Steps

### 1. Push to GitHub

```bash
cd /Users/sarathyv/portal
git add .
git commit -m "Ready for Vercel deployment"
git push origin main
```

### 2. Deploy Backend

1. Go to [vercel.com](https://vercel.com) → Sign in with GitHub
2. Click **"Add New Project"** → Import your repository
3. Configure:
   - **Root Directory**: `backend`
   - **Project Name**: `portal-backend`
4. Add Environment Variables:
   - `FIREBASE_CREDENTIALS_JSON`: Copy from `backend/.env`
   - `SECRET_KEY`: Generate with `openssl rand -hex 32`
   - `ALLOWED_ORIGINS`: `*`
5. Click **Deploy**
6. Copy backend URL: `https://your-backend.vercel.app`

### 3. Deploy Frontend

1. Go to Vercel Dashboard → **"Add New Project"**
2. Import the **SAME repository** again
3. Configure:
   - **Root Directory**: `frontend`
   - **Project Name**: `portal-frontend`
4. Add Environment Variable:
   - `BACKEND_URL`: `https://your-backend.vercel.app` (from step 2.6)
5. Click **Deploy**
6. Copy frontend URL: `https://your-frontend.vercel.app`

### 4. Update Backend CORS

1. Go to Backend Project → Settings → Environment Variables
2. Edit `ALLOWED_ORIGINS`:
   ```
   https://your-frontend.vercel.app,http://localhost:*
   ```
3. Redeploy backend (Deployments → ... → Redeploy)

### 5. Test

- Frontend: `https://your-frontend.vercel.app`
- Backend Health: `https://your-backend.vercel.app/health`
- Login and submit an endpoint to test

---

## ⚙️ Queue Processing

Your backend is configured with a cron job that processes the queue every 5 minutes automatically.

To manually trigger processing:
```bash
curl -X POST https://your-backend.vercel.app/process-queue
```

---

## 🔧 Common Issues

**CORS Error**: Update `ALLOWED_ORIGINS` in backend environment variables

**Build Failed**: Check deployment logs in Vercel dashboard

**Firebase Error**: Verify `FIREBASE_CREDENTIALS_JSON` is correctly set

---

## 📝 Environment Variables Summary

### Backend
- `FIREBASE_CREDENTIALS_JSON`: Your Firebase service account JSON
- `SECRET_KEY`: Random secret key (use `openssl rand -hex 32`)
- `ALLOWED_ORIGINS`: Your frontend URL

### Frontend
- `BACKEND_URL`: Your backend Vercel URL

---

## ✅ Done!

Your platform is live and ready for participants to use!

For detailed documentation, see `VERCEL_DEPLOYMENT.md`
