#!/bin/bash

# Test script to submit a dummy endpoint to the platform

echo "=========================================="
echo "Testing ML Hackathon Platform"
echo "=========================================="
echo ""

# Check if backend is running
echo "1. Checking if backend is running..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✓ Backend is running"
else
    echo "✗ Backend is not running. Please start it first:"
    echo "  docker-compose up -d"
    echo "  OR"
    echo "  cd backend && uvicorn app.main:app --reload"
    exit 1
fi

echo ""

# Submit endpoint
echo "2. Submitting test endpoint..."
RESPONSE=$(curl -s -X POST http://localhost:8000/submit-endpoint \
  -H "Content-Type: application/json" \
  -d '{
    "team_id": "test_team_001",
    "team_name": "Test Warriors",
    "endpoint_url": "http://localhost:5001/predict"
  }')

echo "$RESPONSE" | python3 -m json.tool

TEAM_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['team_id'])" 2>/dev/null)

if [ -z "$TEAM_ID" ]; then
    echo "✗ Submission failed"
    exit 1
fi

echo "✓ Submission successful"
echo ""

# Check queue status
echo "3. Checking queue status..."
sleep 2
curl -s http://localhost:8000/queue-status/$TEAM_ID | python3 -m json.tool
echo ""

# Wait for evaluation
echo "4. Waiting for evaluation to complete..."
for i in {1..10}; do
    STATUS=$(curl -s http://localhost:8000/queue-status/$TEAM_ID | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])" 2>/dev/null)
    echo "   Status: $STATUS"
    
    if [ "$STATUS" = "COMPLETED" ] || [ "$STATUS" = "FAILED" ]; then
        break
    fi
    
    sleep 3
done

echo ""

# Get final results
echo "5. Getting final results..."
curl -s http://localhost:8000/team-result/$TEAM_ID | python3 -m json.tool
echo ""

# Get leaderboard
echo "6. Checking leaderboard..."
curl -s http://localhost:8000/leaderboard | python3 -m json.tool
echo ""

echo "=========================================="
echo "Test completed!"
echo "=========================================="
