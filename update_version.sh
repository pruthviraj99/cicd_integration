#!/bin/bash

# Version update script for Flutter CI/CD
# Usage: ./update_version.sh <patch|minor|major>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <patch|minor|major>"
    exit 1
fi

VERSION_TYPE=$1

if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo "Invalid version type. Use: patch, minor, or major"
    exit 1
fi

echo "Updating version with type: $VERSION_TYPE"

# Run the Dart version manager
dart run scripts/version_manager.dart $VERSION_TYPE

if [ $? -eq 0 ]; then
    echo "Version updated successfully!"
    echo "Current version:"
    grep "version:" pubspec.yaml
else
    echo "Failed to update version"
    exit 1
fi