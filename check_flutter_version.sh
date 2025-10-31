#!/bin/bash

# Script to check Flutter and Dart SDK versions
echo "🔍 Checking Flutter and Dart SDK versions..."
echo ""

# Check local Flutter version
echo "📱 Local Flutter version:"
flutter --version
echo ""

# Check pubspec.yaml requirements
echo "📋 pubspec.yaml requirements:"
grep -A 2 "environment:" pubspec.yaml
echo ""

# Check if versions are compatible
DART_VERSION=$(flutter --version | grep "Dart" | sed 's/.*Dart \([0-9.]*\).*/\1/')
REQUIRED_DART=$(grep "sdk:" pubspec.yaml | sed 's/.*\^\([0-9.]*\).*/\1/')

echo "🔄 Version comparison:"
echo "- Required Dart SDK: ^$REQUIRED_DART"
echo "- Current Dart SDK: $DART_VERSION"
echo ""

# Simple version comparison (basic check)
if [[ "$DART_VERSION" > "$REQUIRED_DART" ]] || [[ "$DART_VERSION" == "$REQUIRED_DART" ]]; then
    echo "✅ Local Flutter version is compatible!"
else
    echo "❌ Local Flutter version may be incompatible"
    echo "💡 Consider upgrading Flutter: flutter upgrade"
fi

echo ""
echo "🚀 CI/CD Pipeline now uses Flutter 3.35.7 (Dart SDK 3.9.2+)"
echo "📍 This should resolve the SDK version conflict in GitHub Actions"