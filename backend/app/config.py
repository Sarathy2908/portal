import os

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
X_TEST_PATH = os.path.join(DATA_DIR, "X_test.csv")
Y_TRUE_PATH = os.path.join(DATA_DIR, "y_true.csv")
FIREBASE_CREDENTIALS_PATH = os.path.join(DATA_DIR, "firebase-credentials.json")

EVALUATION_TIMEOUT = 5
MAX_RETRIES = 1
QUEUE_CHECK_INTERVAL = 5

API_HOST = "0.0.0.0"
API_PORT = 8000

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
