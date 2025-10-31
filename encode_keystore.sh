#!/bin/bash

# Script to encode keystore for GitHub secrets
# This will encode your keystore file to base64 for use in GitHub secrets

KEYSTORE_PATH="android/keystore/cicdintegration.jks"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Keystore not found at: $KEYSTORE_PATH"
    echo "Please make sure your keystore is at the correct location."
    exit 1
fi

echo "🔐 Encoding keystore for GitHub secrets..."
echo ""
echo "📋 Copy this base64 encoded keystore and add it to GitHub secrets as ANDROID_KEYSTORE:"
echo "----------------------------------------"

base64 -i "$KEYSTORE_PATH"

echo ""
echo "----------------------------------------"
echo ""
echo "✅ Also add these secrets to your GitHub repository:"
echo "ANDROID_KEY_ALIAS: cicdintegration"
echo "ANDROID_STORE_PASSWORD: cicd@123"
echo "ANDROID_KEY_PASSWORD: cicd@123"
echo ""
echo "📍 Go to: GitHub Repository → Settings → Secrets and variables → Actions"