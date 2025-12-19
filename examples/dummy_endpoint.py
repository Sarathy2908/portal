"""
Dummy ML Endpoint for Testing
This creates a simple Flask endpoint that returns random predictions
"""

from flask import Flask, request, jsonify
import numpy as np

app = Flask(__name__)

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'status': 'running',
        'message': 'Dummy ML Endpoint for Testing',
        'endpoints': {
            'predict': '/predict (POST)'
        }
    })

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        
        if 'inputs' not in data:
            return jsonify({'error': 'Missing inputs field'}), 400
        
        inputs = data['inputs']
        
        if not isinstance(inputs, list):
            return jsonify({'error': 'Inputs must be a list'}), 400
        
        num_samples = len(inputs)
        predictions = np.random.randint(0, 2, size=num_samples).tolist()
        
        return jsonify({'predictions': predictions})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("=" * 50)
    print("Dummy ML Endpoint Starting...")
    print("=" * 50)
    print("Endpoint: http://localhost:5001/predict")
    print("Method: POST")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5001, debug=True)
