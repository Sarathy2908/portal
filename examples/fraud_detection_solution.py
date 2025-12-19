"""
Example Solution for Credit Card Fraud Detection Challenge

This is a reference implementation showing how to:
1. Train a model on the fraud detection problem
2. Create a REST API endpoint
3. Handle predictions in the required format

Participants should improve upon this baseline!
"""

from flask import Flask, request, jsonify
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score, classification_report
import numpy as np
import time

app = Flask(__name__)

FEATURE_ORDER = [
    'amount', 'time_of_day', 'merchant_category',
    'distance_from_home', 'distance_from_last_transaction',
    'ratio_to_median_purchase', 'repeat_retailer',
    'used_chip', 'used_pin', 'online_order'
]

print("=" * 60)
print("Credit Card Fraud Detection - Example Solution")
print("=" * 60)

print("\nGenerating synthetic training data...")
from sklearn.datasets import make_classification

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

print(f"Training samples: {len(X_train)}")
print(f"Fraud cases: {sum(y_train == 1)} ({sum(y_train == 1)/len(y_train)*100:.1f}%)")
print(f"Legitimate cases: {sum(y_train == 0)} ({sum(y_train == 0)/len(y_train)*100:.1f}%)")

print("\nTraining Random Forest model...")
model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=5,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1
)

model.fit(X_train, y_train)

X_val, y_val = X_train[:1000], y_train[:1000]
y_pred_val = model.predict(X_val)
val_accuracy = accuracy_score(y_val, y_pred_val)
val_f1 = f1_score(y_val, y_pred_val, average='binary')

print(f"\nValidation Results:")
print(f"Accuracy: {val_accuracy:.4f}")
print(f"F1 Score: {val_f1:.4f}")
print("\nClassification Report:")
print(classification_report(y_val, y_pred_val, target_names=['Legitimate', 'Fraud']))

print("\nFeature Importances:")
for feat, imp in zip(FEATURE_ORDER, model.feature_importances_):
    print(f"  {feat:30s}: {imp:.4f}")

@app.route('/predict', methods=['POST'])
def predict():
    """
    Predict fraud for credit card transactions
    
    Expected input format:
    {
        "inputs": [
            {
                "amount": float,
                "time_of_day": float,
                "merchant_category": float,
                "distance_from_home": float,
                "distance_from_last_transaction": float,
                "ratio_to_median_purchase": float,
                "repeat_retailer": float,
                "used_chip": float,
                "used_pin": float,
                "online_order": float
            },
            ...
        ]
    }
    
    Returns:
    {
        "predictions": [0, 1, 0, ...]
    }
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

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model': 'RandomForestClassifier',
        'features': len(FEATURE_ORDER)
    })

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
        'features': FEATURE_ORDER,
        'model_info': {
            'type': 'RandomForestClassifier',
            'n_estimators': 100,
            'validation_accuracy': f"{val_accuracy:.4f}",
            'validation_f1': f"{val_f1:.4f}"
        }
    })

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("Starting Flask API Server")
    print("=" * 60)
    print(f"Endpoint: http://localhost:5001/predict")
    print(f"Health Check: http://localhost:5001/health")
    print("=" * 60)
    print("\nTest with:")
    print("curl -X POST http://localhost:5001/predict \\")
    print("  -H 'Content-Type: application/json' \\")
    print("  -d '{\"inputs\": [{")
    for i, feat in enumerate(FEATURE_ORDER):
        print(f"    \"{feat}\": {np.random.randn():.4f}{',' if i < len(FEATURE_ORDER)-1 else ''}")
    print("  }]}'")
    print("=" * 60 + "\n")
    
    app.run(host='0.0.0.0', port=5001, debug=True)
