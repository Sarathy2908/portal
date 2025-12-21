#!/bin/bash

set -e

echo "Current directory: $(pwd)"
echo "Contents: $(ls -la)"

echo "Installing Flutter..."

# Install Flutter in current directory
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify Flutter installation
flutter --version
flutter doctor

echo "Building Flutter web app..."
echo "Looking for lib/main.dart..."
ls -la lib/

# Get dependencies
flutter pub get

# Build for web with backend URL
flutter build web --release --dart-define=API_BASE_URL=https://portal-v0qp.onrender.com

echo "Build complete!"
