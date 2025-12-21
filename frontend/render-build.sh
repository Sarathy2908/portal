#!/bin/bash

set -e

echo "Installing Flutter..."

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version
flutter doctor

echo "Building Flutter web app..."

# Get dependencies
flutter pub get

# Build for web with backend URL
flutter build web --release --dart-define=API_BASE_URL=https://portal-v0qp.onrender.com

echo "Build complete!"
