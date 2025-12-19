# Quick Deployment Guide
## Intel Server (Backend) + Vercel (Flutter Web)

---

## 🚀 Quick Steps

### 1️⃣ Deploy Backend to Intel Server

**On your Intel server:**

```bash
# Clone repository
git clone https://github.com/yourusername/portal.git
cd portal/backend

# Setup environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file
nano .env
```

Add to `.env`:
```bash
FIREBASE_CREDENTIALS_JSON='{"type":"service_account","project_id":"portal-11326",...}'
SECRET_KEY=change-this-to-random-secret-key
ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3000
```

**Start backend:**
```bash
./deploy.sh production
```

Or with systemd (recommended):
```bash
sudo cp ml-hackathon.service /etc/systemd/system/
sudo systemctl enable ml-hackathon
sudo systemctl start ml-hackathon
```

**Your backend will be at:** `http://your-server-ip:8000`

---

### 2️⃣ Deploy Frontend to Vercel

**Step 1: Push to GitHub**
```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

**Step 2: Deploy on Vercel**

1. Go to [vercel.com](https://vercel.com) → New Project
2. Import your GitHub repository
3. Configure:
   - **Root Directory:** `frontend`
   - **Framework:** Other
   - **Build Command:** `flutter build web --dart-define=API_BASE_URL=$API_BASE_URL`
   - **Output Directory:** `build/web`

4. **Add Environment Variable:**
   - Name: `API_BASE_URL`
   - Value: `http://your-server-ip:8000` (or `https://api.yourdomain.com`)

5. Click **Deploy**

**Your frontend will be at:** `https://your-app.vercel.app`

---

## 🔧 Configure CORS

**Update backend `.env` on Intel server:**
```bash
ALLOWED_ORIGINS=https://your-app.vercel.app
```

**Restart backend:**
```bash
sudo systemctl restart ml-hackathon
```

---

## ✅ Test Your Deployment

1. **Backend Health Check:**
   ```bash
   curl http://your-server-ip:8000/health
   ```
   Should return: `{"status":"healthy"}`

2. **Frontend:**
   - Open `https://your-app.vercel.app`
   - Try to login
   - Submit an endpoint
   - Check leaderboard

---

## 🔒 Production Checklist

- [ ] Change `SECRET_KEY` in `.env` to a strong random value
- [ ] Set `ALLOWED_ORIGINS` to your Vercel domain (not `*`)
- [ ] Setup SSL/HTTPS on Intel server (use nginx + certbot)
- [ ] Configure firewall on Intel server
- [ ] Test Firebase authentication
- [ ] Test endpoint submission and evaluation
- [ ] Monitor backend logs

---

## 📊 URLs Summary

| Service | URL | Purpose |
|---------|-----|---------|
| Backend API | `http://your-server-ip:8000` | FastAPI backend |
| Frontend | `https://your-app.vercel.app` | Flutter web app |
| Backend Health | `http://your-server-ip:8000/health` | Health check |
| API Docs | `http://your-server-ip:8000/docs` | Swagger UI |

---

## 🆘 Common Issues

**CORS Error:**
- Add your Vercel domain to `ALLOWED_ORIGINS` in backend `.env`
- Restart backend service

**Firebase Auth Error:**
- Check `FIREBASE_CREDENTIALS_JSON` in `.env`
- Verify Firebase project ID matches

**Can't connect to backend:**
- Check backend is running: `sudo systemctl status ml-hackathon`
- Check firewall allows port 8000
- Verify `API_BASE_URL` in Vercel environment variables

---

## 📖 Full Documentation

See `DEPLOYMENT.md` for complete deployment guide with:
- SSL/HTTPS setup
- Nginx reverse proxy
- Systemd service configuration
- Security hardening
- Monitoring and logs
