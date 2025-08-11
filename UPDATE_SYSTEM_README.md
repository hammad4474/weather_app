# Weather App Update System

## Overview
This weather app now includes an automatic update checking system that will notify users when new versions are available.

## Features

### 1. Automatic Update Check
- **When**: Every time the app starts (after splash screen)
- **What**: Compares current app version with the latest available version
- **Result**: Shows update dialog if newer version is available

### 2. Manual Update Check
- **Where**: New update button in the app bar (next to theme toggle)
- **Icon**: System update icon (🔄)
- **Tooltip**: "Check for Updates"

### 3. Update Dialog
- Shows current vs. latest version
- Displays "What's new" information
- Options: "Later" or "Update Now"
- "Update Now" opens Play Store

### 4. Up-to-Date Notification
- Green snackbar message when app is current
- Shows for 2 seconds
- Non-intrusive

## How to Update the App

### For Developers (You)

1. **Update Version Numbers** in `lib/Services/update_service.dart`:
   ```dart
   static const String latestVersion = '2.1.0';  // Change this
   static const String latestVersionCode = '4';   // Change this
   ```

2. **Update pubspec.yaml**:
   ```yaml
   version: 2.0.1+3  # Change to new version
   ```

3. **Build and Release**:
   ```bash
   flutter build appbundle
   ```

4. **Upload to Play Store** with higher version code

### For Users

1. **Automatic**: App checks for updates on startup
2. **Manual**: Tap the update button in the app bar
3. **Update**: Tap "Update Now" to go to Play Store

## Configuration

### Current Settings
- **Package Name**: `com.hammad.weather_app`
- **Update Check**: On app start + manual button
- **Dialog Style**: Material Design with app theme colors
- **Fallback**: Web Play Store if app store unavailable

### Customization Options
You can modify these in `lib/Services/update_service.dart`:

- **Dialog Appearance**: Colors, text, icons
- **Update Logic**: Version comparison method
- **What's New**: Change the update description
- **Timing**: When to check for updates

## Technical Details

### Dependencies Added
- `package_info_plus: ^8.0.2` - Get app version info
- `url_launcher: ^6.3.1` - Open Play Store links

### Files Modified
- `lib/main.dart` - Added update check on app start
- `lib/view/weather_app_homescreen.dart` - Added update button
- `lib/Services/update_service.dart` - New update service

### Integration Points
- **App Start**: `main.dart` calls update check
- **App Bar**: Manual update button with icon
- **Service**: Centralized update logic

## Testing

### Test Update Dialog
1. Change `latestVersionCode` to a number higher than current
2. Run the app
3. Update dialog should appear

### Test Up-to-Date Message
1. Ensure `latestVersionCode` matches current app version
2. Run the app
3. Green "up to date" message should appear

### Test Manual Check
1. Tap the update button in app bar
2. Should trigger update check immediately

## Future Enhancements

### Server-Side Version Checking
```dart
// Replace hardcoded version with API call
final response = await http.get('https://your-api.com/app-version');
final latestVersion = jsonDecode(response.body)['version'];
```

### In-App Updates
- Use `in_app_updater` package for direct APK downloads
- Implement delta updates for smaller downloads
- Add update progress indicators

### Custom Update Sources
- Support for beta/alpha channels
- Multiple update sources
- Update scheduling options

## Troubleshooting

### Common Issues
1. **Update button not visible**: Check import of `UpdateService`
2. **Dialog not showing**: Verify version numbers are correct
3. **Play Store not opening**: Check package name in service
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Debug Information
The service logs version information to console:
```
Current app version: 2.0.1+3
Latest available version: 2.1.0+4
```

## Support
If you encounter issues with the update system, check:
1. Console logs for error messages
2. Version numbers in both files
3. Package dependencies are installed
4. App permissions for internet access 