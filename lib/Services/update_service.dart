import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // You can update this version when you release a new version
  static const String latestVersion = '2.1.0';
  static const String latestVersionCode = '4';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String currentBuildNumber = packageInfo.buildNumber;

      debugPrint('Current app version: $currentVersion+$currentBuildNumber');
      debugPrint('Latest available version: $latestVersion+$latestVersionCode');

      // Simple version comparison (you can enhance this with server-side checking)
      if (_shouldShowUpdateDialog(currentVersion, currentBuildNumber)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion);
        }
      } else {
        debugPrint('App is up to date');
        // Optionally show a message that app is up to date
        if (context.mounted) {
          _showUpToDateMessage(context);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  // Simple version comparison logic
  static bool _shouldShowUpdateDialog(
    String currentVersion,
    String currentBuildNumber,
  ) {
    try {
      // Compare version codes (build numbers)
      int current = int.tryParse(currentBuildNumber) ?? 0;
      int latest = int.tryParse(latestVersionCode) ?? 0;

      return current < latest;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  // Custom update dialog
  static void _showUpdateDialog(BuildContext context, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.system_update,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Update Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version of Weather App is available!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getCurrentVersionInfo(),
                builder: (context, snapshot) {
                  return Text(
                    'Current Version: ${snapshot.data ?? 'Loading...'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  );
                },
              ),
              Text(
                'Latest Version: v$version',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'What\'s new:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                '• New automatic update system\n• Enhanced weather accuracy\n• Better user experience\n• Improved app performance',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Later'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Open Play Store for update
                _openPlayStore();
              },
              icon: Icon(Icons.download),
              label: Text('Update Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Show up-to-date message
  static void _showUpToDateMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Your app is up to date!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Get current version info
  static Future<String> _getCurrentVersionInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Open Play Store for app update
  static Future<void> _openPlayStore() async {
    try {
      // Replace with your actual Play Store package name
      const String packageName = 'com.hammad.weather_app';
      final Uri url = Uri.parse('market://details?id=$packageName');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web URL
        final Uri webUrl = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName',
        );
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening Play Store: $e');
    }
  }

  // Method to manually check for updates (can be called from settings or refresh button)
  static Future<void> manualUpdateCheck(BuildContext context) async {
    await checkForUpdates(context);
  }
}
