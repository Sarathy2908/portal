"""
Vercel-compatible version of the Fraud Detection API
"""

from flask import Flask, request, jsonify
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
from sklearn.metrics import accuracy_score, f1_score
import numpy as np
import time

app = Flask(__name__)

FEATURE_ORDER = [
    'amount', 'time_of_day', 'merchant_category',
    'distance_from_home', 'distance_from_last_transaction',
    'ratio_to_median_purchase', 'repeat_retailer',
    'used_chip', 'used_pin', 'online_order'
]

# Train model on startup
print("Training model...")
X_train, y_train = make_classification(
    n_samples=5000,
    n_features=10,
    n_informative=8,
    n_redundant=2,
    n_classes=2,
    weights=[0.9, 0.1],
    flip_y=0.05,
    random_state=123
)

model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=5,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1
)

model.fit(X_train, y_train)
print("Model trained successfully!")

@app.route('/', methods=['GET'])
def home():
    """API information"""
    return jsonify({
        'name': 'Credit Card Fraud Detection API',
        'version': '1.0',
        'endpoints': {
            '/predict': 'POST - Make fraud predictions',
            '/health': 'GET - Health check'
        },
        'features': FEATURE_ORDER
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'RandomForestClassifier',
        'features': len(FEATURE_ORDER)
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Predict fraud for credit card transactions
    """
    start_time = time.time()
    
    try:
        data = request.get_json()
        
        if not data or 'inputs' not in data:
            return jsonify({'error': 'Missing inputs field'}), 400
        
        inputs = data['inputs']
        
        if not isinstance(inputs, list) or len(inputs) == 0:
            return jsonify({'error': 'Inputs must be a non-empty list'}), 400
        
        features = []
        for item in inputs:
            feature_vector = [item.get(feat, 0) for feat in FEATURE_ORDER]
            features.append(feature_vector)
        
        features_array = np.array(features)
        predictions = model.predict(features_array)
        
        latency_ms = (time.time() - start_time) * 1000
        
        return jsonify({
            'predictions': predictions.tolist(),
            'latency_ms': latency_ms
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# For Vercel
def handler(request):
    return app(request)
