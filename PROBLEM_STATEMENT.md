# 🎯 ML Hackathon Challenge: Credit Card Fraud Detection

## Problem Overview

Build a machine learning model to detect fraudulent credit card transactions in real-time. Your model will be evaluated on accuracy, F1 score, and response latency.

---

## 📊 Dataset Description

### Features (10 total):

1. **amount** - Transaction amount (normalized)
2. **time_of_day** - Time when transaction occurred (normalized)
3. **merchant_category** - Type of merchant (normalized)
4. **distance_from_home** - Distance from cardholder's home (normalized)
5. **distance_from_last_transaction** - Distance from previous transaction (normalized)
6. **ratio_to_median_purchase** - Ratio of this purchase to median purchase amount
7. **repeat_retailer** - Whether merchant was used before (normalized)
8. **used_chip** - Whether chip was used (normalized)
9. **used_pin** - Whether PIN was entered (normalized)
10. **online_order** - Whether transaction was online (normalized)

### Target Variable:
- **0** = Legitimate transaction
- **1** = Fraudulent transaction

### Dataset Statistics:
- **Total transactions**: 1,000
- **Class distribution**: ~90% legitimate, ~10% fraudulent (imbalanced)
- **All features**: Continuous values (normalized)

---

## 🎯 Task

Build a binary classification model that:
1. Accepts transaction features via REST API
2. Predicts fraud (1) or legitimate (0) for each transaction
3. Returns predictions in the required format

---

## 🔌 API Specification

### Endpoint Requirements

**Method**: `POST`  
**Path**: `/predict`  
**Content-Type**: `application/json`

### Request Format

```json
{
  "inputs": [
    {
      "amount": -0.5234,
      "time_of_day": 1.2341,
      "merchant_category": 0.8765,
      "distance_from_home": -0.3421,
      "distance_from_last_transaction": 0.9876,
      "ratio_to_median_purchase": 1.4532,
      "repeat_retailer": -0.2341,
      "used_chip": 0.5678,
      "used_pin": -0.8765,
      "online_order": 0.3456
    },
    {
      "amount": 0.1234,
      "time_of_day": -0.5678,
      ...
    }
  ]
}
```

### Response Format

```json
{
  "predictions": [0, 1, 0, 0, 1, ...]
}
```

- **predictions**: Array of integers (0 or 1)
- Length must match number of inputs
- **0** = Legitimate, **1** = Fraud

---

## 📈 Evaluation Metrics

Your model will be ranked based on:

1. **Accuracy** (Primary) - Overall correctness
2. **F1 Score** (Secondary) - Balance of precision and recall (important for imbalanced data)
3. **Latency** (Tertiary) - Response time in milliseconds

**Ranking Formula**:
- Sort by: Accuracy (DESC) → F1 Score (DESC) → Latency (ASC)

---

## 🚀 Getting Started

### Step 1: Build Your Model

```python
# Example: Train a model
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import pandas as pd

# Load your training data (you need to create/find this)
# X_train, y_train = load_training_data()

# Train model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Save model
import joblib
joblib.dump(model, 'fraud_model.pkl')
```

### Step 2: Create API Endpoint

```python
from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)
model = joblib.load('fraud_model.pkl')

FEATURE_ORDER = [
    'amount', 'time_of_day', 'merchant_category',
    'distance_from_home', 'distance_from_last_transaction',
    'ratio_to_median_purchase', 'repeat_retailer',
    'used_chip', 'used_pin', 'online_order'
]

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    inputs = data.get('inputs', [])
    
    # Extract features in correct order
    features = []
    for item in inputs:
        feature_vector = [item.get(feat, 0) for feat in FEATURE_ORDER]
        features.append(feature_vector)
    
    # Make predictions
    predictions = model.predict(features).tolist()
    
    return jsonify({'predictions': predictions})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
```

### Step 3: Test Locally

```bash
# Start your endpoint
python your_endpoint.py

# Test with curl
curl -X POST http://localhost:5001/predict \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": [
      {
        "amount": -0.5234,
        "time_of_day": 1.2341,
        "merchant_category": 0.8765,
        "distance_from_home": -0.3421,
        "distance_from_last_transaction": 0.9876,
        "ratio_to_median_purchase": 1.4532,
        "repeat_retailer": -0.2341,
        "used_chip": 0.5678,
        "used_pin": -0.8765,
        "online_order": 0.3456
      }
    ]
  }'
```

### Step 4: Submit to Portal

1. Deploy your endpoint (locally or cloud)
2. Go to the hackathon portal
3. Sign up / Log in
4. Submit your endpoint URL
5. Wait for evaluation results

---

## 💡 Tips for Success

### Model Selection
- Try multiple algorithms: Logistic Regression, Random Forest, XGBoost, Neural Networks
- Handle class imbalance: Use SMOTE, class weights, or ensemble methods
- Feature engineering: Create interaction features, polynomial features

### Optimization
- **For Accuracy**: Focus on overall correctness
- **For F1 Score**: Balance precision and recall (critical for fraud detection)
- **For Latency**: Optimize model size, use caching, efficient preprocessing

### Common Pitfalls
- ❌ Not handling all 10 features in correct order
- ❌ Returning wrong data type (must be integers 0 or 1)
- ❌ Not handling imbalanced classes
- ❌ Slow response times (> 5 seconds timeout)

---

## 🏆 Winning Strategy

1. **Data Understanding**: Analyze feature importance
2. **Preprocessing**: Proper scaling and handling missing values
3. **Model Selection**: Try ensemble methods (Random Forest, XGBoost)
4. **Hyperparameter Tuning**: Use GridSearch or RandomSearch
5. **Class Imbalance**: Use SMOTE or class weights
6. **Validation**: Use stratified k-fold cross-validation
7. **Optimization**: Balance accuracy with speed

---

## 📝 Submission Checklist

Before submitting, ensure:

- ✅ Endpoint accepts POST requests at `/predict`
- ✅ Handles JSON input with all 10 features
- ✅ Returns JSON with `predictions` array
- ✅ Predictions are integers (0 or 1)
- ✅ Response length matches input length
- ✅ Endpoint is accessible (not blocked by firewall)
- ✅ Response time < 5 seconds
- ✅ Tested with sample data

---

## 🎓 Resources

### Machine Learning Libraries
- **scikit-learn**: Classic ML algorithms
- **XGBoost**: Gradient boosting
- **LightGBM**: Fast gradient boosting
- **TensorFlow/PyTorch**: Deep learning

### Handling Imbalanced Data
- **SMOTE**: Synthetic minority oversampling
- **Class weights**: Penalize misclassifications differently
- **Ensemble methods**: Combine multiple models

### API Frameworks
- **Flask**: Simple and lightweight
- **FastAPI**: Modern, fast, with automatic docs
- **Django REST**: Full-featured framework

---

## 🆘 Support

If you encounter issues:
1. Check your endpoint returns correct format
2. Verify all 10 features are included
3. Test locally before submitting
4. Check portal logs for error messages

---

## 🏁 Ready to Compete?

1. Build your best fraud detection model
2. Deploy as a REST API
3. Submit to the portal
4. Climb the leaderboard!

**Good luck! 🚀**
