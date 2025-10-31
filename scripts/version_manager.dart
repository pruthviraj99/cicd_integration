import 'dart:io';
import 'dart:convert';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart version_manager.dart <patch|minor|major>');
    exit(1);
  }

  final versionType = args[0];
  if (!['patch', 'minor', 'major'].contains(versionType)) {
    print('Invalid version type. Use: patch, minor, or major');
    exit(1);
  }

  updateVersion(versionType);
}

void updateVersion(String type) {
  // Read pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('pubspec.yaml not found');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final lines = content.split('\n');
  
  String? versionLine;
  int versionLineIndex = -1;
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('version:')) {
      versionLine = lines[i];
      versionLineIndex = i;
      break;
    }
  }
  
  if (versionLine == null) {
    print('Version not found in pubspec.yaml');
    exit(1);
  }

  // Extract current version
  final versionMatch = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)').firstMatch(versionLine);
  if (versionMatch == null) {
    print('Invalid version format in pubspec.yaml');
    exit(1);
  }

  int major = int.parse(versionMatch.group(1)!);
  int minor = int.parse(versionMatch.group(2)!);
  int patch = int.parse(versionMatch.group(3)!);
  int buildNumber = int.parse(versionMatch.group(4)!);

  // Increment version based on type
  switch (type) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
  }

  buildNumber++;

  final newVersion = '$major.$minor.$patch+$buildNumber';
  lines[versionLineIndex] = 'version: $newVersion';

  // Write back to pubspec.yaml
  pubspecFile.writeAsStringSync(lines.join('\n'));

  // Update Android build.gradle.kts
  updateAndroidVersion(major, minor, patch, buildNumber);

  print('Version updated to: $major.$minor.$patch ($buildNumber)');
}

void updateAndroidVersion(int major, int minor, int patch, int buildNumber) {
  final buildGradleFile = File('android/app/build.gradle.kts');
  if (!buildGradleFile.existsSync()) {
    print('Android build.gradle.kts not found');
    return;
  }

  String content = buildGradleFile.readAsStringSync();
  
  // Update versionCode
  content = content.replaceAll(
    RegExp(r'versionCode\s*=\s*\d+'),
    'versionCode = $buildNumber'
  );
  
  // Update versionName
  content = content.replaceAll(
    RegExp(r'versionName\s*=\s*"[^"]*"'),
    'versionName = "$major.$minor.$patch"'
  );

  buildGradleFile.writeAsStringSync(content);
  print('Android version updated');
}