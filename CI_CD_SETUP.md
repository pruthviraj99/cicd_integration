# CI/CD Setup Guide

This guide will help you set up the complete CI/CD pipeline for your Flutter app with GitHub Actions, Fastlane, and Google Play Store deployment.

## Prerequisites

1. **GitHub Repository**: Your code should be in a GitHub repository
2. **Google Play Console Account**: You need a Google Play Console account
3. **Android Keystore**: You need a release keystore for signing your app

## Setup Steps

### 1. Android Keystore (Already Created)

Your keystore is already created at:
- **Path**: `/Users/pruthvirajsinhgohil/Documents/Workspace/cicd_integration/android/keystore/cicdintegration.jks`
- **Alias**: `cicdintegration`
- **Store Password**: `cicd@123`
- **Key Password**: `cicd@123`

### 2. Google Play Console Setup

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app or select existing app
3. Go to **Setup** → **API access**
4. Create a new service account or use existing one
5. Download the JSON key file
6. Grant necessary permissions to the service account

### 3. GitHub Secrets Configuration

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

#### Required Secrets:

- **ANDROID_KEYSTORE**: Base64 encoded keystore file
  ```bash
  base64 -i android/app/keystore.jks | pbcopy
  ```

- **ANDROID_KEY_ALIAS**: `cicdintegration`

- **ANDROID_STORE_PASSWORD**: `cicd@123`

- **ANDROID_KEY_PASSWORD**: `cicd@123`

- **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON**: Content of your Google Play service account JSON file

### 4. Local Development Setup

1. **Install Fastlane**:
   ```bash
   cd android
   bundle install
   ```

2. **key.properties** (already created):
   ```bash
   # android/key.properties
   storeFile=keystore/cicdintegration.jks
   keyAlias=cicdintegration
   storePassword=cicd@123
   keyPassword=cicd@123
   ```

3. **Add to .gitignore**:
   ```
   android/key.properties
   android/app/keystore.jks
   android/fastlane/google-play-api-key.json
   ```

## Usage

### Automatic Deployment

1. **Push to develop branch**: Automatically increments patch version, generates artifacts, and deploys to internal testing
2. **Push to release branch**: Automatically increments minor version, generates artifacts, and deploys to production
3. **Manual deployment**: Use GitHub Actions workflow dispatch to choose version type and deployment track

### Manual Version Management

```bash
# Increment patch version (1.0.0 → 1.0.1)
dart run scripts/version_manager.dart patch

# Increment minor version (1.0.1 → 1.1.0)
dart run scripts/version_manager.dart minor

# Increment major version (1.1.0 → 2.0.0)
dart run scripts/version_manager.dart major
```

### Fastlane Commands

```bash
cd android

# Build debug APK
bundle exec fastlane build_debug

# Build release APK
bundle exec fastlane build_release

# Deploy to internal testing
bundle exec fastlane internal

# Deploy to beta
bundle exec fastlane beta

# Deploy to production
bundle exec fastlane production

# Increment version
bundle exec fastlane increment_version type:patch
bundle exec fastlane increment_version type:minor
bundle exec fastlane increment_version type:major
```

## Workflow Triggers

### Automatic Triggers:
- **Push to develop**: Runs tests, increments patch version, generates artifacts, deploys to internal testing
- **Push to release**: Runs tests, increments minor version, generates artifacts, deploys to production
- **Pull Request**: Runs tests and builds debug APK as artifact

### Manual Triggers:
- **Workflow Dispatch**: Choose version increment type and deployment track, generates artifacts

## File Structure

```
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── android/
│   ├── fastlane/
│   │   ├── Appfile
│   │   └── Fastfile
│   ├── Gemfile
│   └── key.properties (local only)
├── scripts/
│   └── version_manager.dart
└── CI_CD_SETUP.md
```

## Troubleshooting

### Common Issues:

1. **Keystore not found**: Ensure keystore is properly encoded and added to GitHub secrets
2. **Google Play API errors**: Verify service account permissions and JSON key
3. **Version conflicts**: Ensure version codes are incremental
4. **Build failures**: Check Flutter and Android SDK versions

### Debug Commands:

```bash
# Test Fastlane setup
cd android
bundle exec fastlane test

# Validate Google Play API
bundle exec fastlane run validate_play_store_json_key

# Check version info
flutter --version
```

## Security Notes

- Never commit keystore files or API keys to version control
- Use GitHub secrets for all sensitive information
- Regularly rotate API keys and passwords
- Review service account permissions periodically

## Version Management Strategy

- **Patch (x.x.X)**: Bug fixes, small updates
- **Minor (x.X.x)**: New features, backwards compatible
- **Major (X.x.x)**: Breaking changes, major updates

The build number is automatically incremented with each deployment to ensure unique version codes for the Play Store.
## Enhan
ced CI/CD Workflow with Artifacts

### Complete Build + Deploy Process

Every deployment now follows this enhanced workflow:

1. **Build Artifacts**: Generate both APK and AAB files
2. **Upload Artifacts**: Store builds in GitHub Actions for download
3. **Deploy to Play Store**: Automatically upload to the appropriate track
4. **Generate Summary**: Provide detailed deployment information

### Branch-Specific Behavior

#### Develop Branch (`develop`)
- **Version**: Auto-increment patch (1.0.0 → 1.0.1)
- **Artifacts**: `develop-apk-{sha}` and `develop-aab-{sha}` (15 days retention)
- **Deployment**: Internal testing track
- **Use Case**: Daily development builds and testing

#### Release Branch (`release`)
- **Version**: Auto-increment minor (1.0.1 → 1.1.0)
- **Artifacts**: `release-apk-{sha}` and `release-aab-{sha}` (30 days retention)
- **Deployment**: Production track
- **Use Case**: Official releases to end users

#### Manual Deployment
- **Version**: Choose increment type (patch/minor/major)
- **Artifacts**: `manual-apk-{type}-{sha}` and `manual-aab-{type}-{sha}` (30 days retention)
- **Deployment**: Choose track (internal/beta/production)
- **Use Case**: Hotfixes, special releases, or testing different tracks

### Artifact Management

**Download Artifacts**:
```bash
# List recent builds with artifacts
./scripts/download_artifacts.sh

# Download specific build artifacts
./scripts/download_artifacts.sh 1234567890

# Or use GitHub CLI
gh run download [run_id]
```

**Artifact Naming Convention**:
- `develop-apk-{commit-sha}` - Development APK builds
- `develop-aab-{commit-sha}` - Development AAB builds
- `release-apk-{commit-sha}` - Production APK builds
- `release-aab-{commit-sha}` - Production AAB builds
- `manual-apk-{version-type}-{commit-sha}` - Manual APK builds
- `manual-aab-{version-type}-{commit-sha}` - Manual AAB builds

### Deployment Summary

Each successful deployment provides:
- ✅ Build information (version, build number, commit)
- 📦 Artifact download links
- 🎯 Deployment status and track
- 📱 Play Console upload confirmation

### Benefits

1. **Backup & Recovery**: All builds are preserved as artifacts
2. **Testing**: Download and test exact builds before/after deployment
3. **Rollback**: Access previous builds if needed
4. **Audit Trail**: Complete history of all builds and deployments
5. **Parallel Testing**: Test APK while AAB is deployed to Play Store

### Quick Start

1. **Push to develop** for internal testing with artifacts
2. **Push to release** for production deployment with artifacts
3. **Use manual workflow** for custom version increments and tracks
4. **Download artifacts** using the provided scripts for testing
5. **Monitor deployments** via GitHub Actions summaries