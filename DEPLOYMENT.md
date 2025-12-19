# ML Hackathon Platform - Deployment Guide

This guide explains how to deploy the ML Hackathon Platform with:
- **Backend**: Intel Server (FastAPI)
- **Frontend**: Vercel (Flutter Web)
- **Database**: Firebase Firestore

---

## 🏗️ Architecture

```
┌─────────────────────┐         ┌──────────────────────┐         ┌─────────────────┐
│  Flutter Web App    │ HTTPS   │  Backend API         │  Auth   │   Firebase      │
│  (Vercel)           │ ──────> │  (Intel Server)      │ ──────> │  (Firestore)    │
│  your-app.vercel.app│         │  api.yourdomain.com  │         │                 │
└─────────────────────┘         └──────────────────────┘         └─────────────────┘
```

---

## 📋 Prerequisites

- Intel server with Ubuntu/Debian (or any Linux)
- Domain name (optional but recommended)
- Firebase project with Firestore enabled
- Vercel account
- Git repository (GitHub, GitLab, etc.)

---

## 🖥️ Part 1: Backend Deployment (Intel Server)

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.11+
sudo apt install python3 python3-pip python3-venv -y

# Install nginx (for reverse proxy)
sudo apt install nginx -y

# Install certbot (for SSL)
sudo apt install certbot python3-certbot-nginx -y
```

### Step 2: Deploy Backend Code

```bash
# Clone your repository
cd /var/www
sudo git clone https://github.com/yourusername/portal.git
cd portal/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables

```bash
# Create .env file
nano .env
```

Add your Firebase credentials:
```bash
FIREBASE_CREDENTIALS_JSON='{"type":"service_account","project_id":"portal-11326",...}'
SECRET_KEY=your-production-secret-key-change-this
```

### Step 4: Create Systemd Service

```bash
sudo nano /etc/systemd/system/ml-hackathon.service
```

Add:
```ini
[Unit]
Description=ML Hackathon Backend API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/portal/backend
Environment="PATH=/var/www/portal/backend/venv/bin"
ExecStart=/var/www/portal/backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable ml-hackathon
sudo systemctl start ml-hackathon
sudo systemctl status ml-hackathon
```

### Step 5: Configure Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/ml-hackathon
```

Add:
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;  # Replace with your domain

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/ml-hackathon /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 6: Setup SSL Certificate

```bash
sudo certbot --nginx -d api.yourdomain.com
```

### Step 7: Update CORS Configuration

Edit `backend/app/main.py` to allow your Vercel domain:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-app.vercel.app",  # Your Vercel domain
        "http://localhost:*",            # Local development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Restart the service:
```bash
sudo systemctl restart ml-hackathon
```

---

## 🌐 Part 2: Frontend Deployment (Vercel)

### Step 1: Prepare Flutter for Web

```bash
cd frontend
flutter pub get
flutter build web --release
```

### Step 2: Push to GitHub

```bash
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

### Step 3: Deploy to Vercel

1. **Go to [vercel.com](https://vercel.com)** and sign in
2. **Import your repository**
3. **Configure project**:
   - Framework Preset: **Other**
   - Root Directory: `frontend`
   - Build Command: `flutter build web --dart-define=API_BASE_URL=$API_BASE_URL`
   - Output Directory: `build/web`

4. **Add Environment Variable**:
   - Key: `API_BASE_URL`
   - Value: `https://api.yourdomain.com` (your backend URL)

5. **Deploy**

### Step 4: Configure Custom Domain (Optional)

In Vercel dashboard:
- Go to Settings → Domains
- Add your custom domain
- Update DNS records as instructed

---

## 🔧 Part 3: Backend CORS Update

Update the backend to allow your Vercel domain. I'll create a configuration file:

```bash
cd backend
nano app/config.py
```

Add:
```python
# CORS Configuration
ALLOWED_ORIGINS = [
    "https://your-app.vercel.app",
    "http://localhost:3000",
    "http://localhost:8080",
]
```

---

## ✅ Verification Checklist

### Backend (Intel Server)
- [ ] Backend service running: `sudo systemctl status ml-hackathon`
- [ ] Nginx configured and running: `sudo systemctl status nginx`
- [ ] SSL certificate installed: `https://api.yourdomain.com`
- [ ] API responding: `curl https://api.yourdomain.com/health`
- [ ] Firebase connected (check logs)
- [ ] CORS configured for Vercel domain

### Frontend (Vercel)
- [ ] Build successful on Vercel
- [ ] Environment variable `API_BASE_URL` set
- [ ] App accessible at Vercel URL
- [ ] Can login with Firebase
- [ ] Can submit endpoints
- [ ] Leaderboard loads

---

## 🔍 Troubleshooting

### Backend Issues

**Service won't start:**
```bash
sudo journalctl -u ml-hackathon -f
```

**Port 8000 already in use:**
```bash
sudo lsof -i :8000
sudo kill -9 <PID>
```

**Firebase authentication errors:**
- Check `.env` file has correct credentials
- Verify Firebase project ID matches
- Check server can reach googleapis.com

### Frontend Issues

**CORS errors:**
- Add Vercel domain to backend CORS configuration
- Restart backend service
- Clear browser cache

**API connection failed:**
- Verify `API_BASE_URL` environment variable in Vercel
- Check backend is accessible: `curl https://api.yourdomain.com`
- Check SSL certificate is valid

**Build fails on Vercel:**
- Ensure Flutter SDK is compatible
- Check build logs in Vercel dashboard
- Verify `vercel.json` configuration

---

## 🔐 Security Checklist

- [ ] Change default `SECRET_KEY` in `.env`
- [ ] Firebase credentials in `.env` (not in code)
- [ ] SSL certificate installed (HTTPS)
- [ ] Firewall configured (only ports 80, 443, 22 open)
- [ ] Regular security updates: `sudo apt update && sudo apt upgrade`
- [ ] Strong passwords for server access
- [ ] SSH key-based authentication enabled

---

## 📊 Monitoring

### Backend Logs
```bash
# Service logs
sudo journalctl -u ml-hackathon -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Performance
```bash
# Check CPU/Memory
htop

# Check disk space
df -h

# Check network
netstat -tuln
```

---

## 🔄 Updates and Maintenance

### Update Backend Code
```bash
cd /var/www/portal
sudo git pull origin main
cd backend
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart ml-hackathon
```

### Update Frontend
Push to GitHub, Vercel will auto-deploy:
```bash
git add .
git commit -m "Update frontend"
git push origin main
```

---

## 📞 Support

For issues:
1. Check logs (backend and nginx)
2. Verify environment variables
3. Test API endpoints with curl
4. Check Firebase console for errors
5. Review Vercel build logs

---

## 🎉 Success!

Your ML Hackathon Platform is now live:
- **Frontend**: https://your-app.vercel.app
- **Backend**: https://api.yourdomain.com
- **Status**: https://api.yourdomain.com/health

Participants can now:
1. Sign up and login
2. Submit their ML model endpoints
3. Get evaluated on 1000 fraud detection test cases
4. See results on the leaderboard
