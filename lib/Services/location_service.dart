import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Main method to get current location with smart fallbacks
  Future<String> getCurrentLocationCity() async {
    try {
      debugPrint('🗺️ Starting location detection...');

      // Try fast location first (3 seconds timeout)
      try {
        String fastLocation = await _getFastLocation();
        debugPrint('✅ Fast location success: $fastLocation');
        return fastLocation;
      } catch (e) {
        debugPrint('⚠️ Fast location failed: $e');
      }

      // Try medium accuracy with longer timeout
      try {
        String mediumLocation = await _getMediumLocation();
        debugPrint('✅ Medium location success: $mediumLocation');
        return mediumLocation;
      } catch (e) {
        debugPrint('⚠️ Medium location failed: $e');
      }

      // Last resort - try with last known position
      try {
        String lastKnownLocation = await _getLastKnownLocation();
        debugPrint('✅ Last known location success: $lastKnownLocation');
        return lastKnownLocation;
      } catch (e) {
        debugPrint('⚠️ Last known location failed: $e');
      }

      // If all methods fail, throw exception
      throw Exception('Unable to determine location after multiple attempts');
    } catch (e) {
      debugPrint('❌ All location methods failed: $e');
      rethrow;
    }
  }

  /// Fast location detection (3 seconds, low accuracy)
  Future<String> _getFastLocation() async {
    if (!await _checkBasicRequirements()) {
      throw Exception('Location requirements not met');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: Duration(seconds: 3), // Very short timeout
    );

    return await _getCityFromCoordinates(position.latitude, position.longitude);
  }

  /// Medium accuracy location (5 seconds timeout)
  Future<String> _getMediumLocation() async {
    if (!await _checkBasicRequirements()) {
      throw Exception('Location requirements not met');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 5),
    );

    return await _getCityFromCoordinates(position.latitude, position.longitude);
  }

  /// Get last known position
  Future<String> _getLastKnownLocation() async {
    Position? lastPosition = await Geolocator.getLastKnownPosition();

    if (lastPosition == null) {
      throw Exception('No last known position available');
    }

    return await _getCityFromCoordinates(
      lastPosition.latitude,
      lastPosition.longitude,
    );
  }

  /// Check basic requirements quickly
  Future<bool> _checkBasicRequirements() async {
    try {
      // Quick permission check with timeout
      final permissionFuture = _ensurePermissions();
      final locationServiceFuture = Geolocator.isLocationServiceEnabled();

      // Wait for both with timeout
      final results = await Future.wait([
        permissionFuture,
        locationServiceFuture,
      ]).timeout(Duration(seconds: 2));

      bool hasPermission = results[0] as bool;
      bool serviceEnabled = results[1] as bool;

      if (!serviceEnabled) {
        throw Exception('Location services disabled');
      }

      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Basic requirements check failed: $e');
      return false;
    }
  }

  /// Quick permission check and request
  Future<bool> _ensurePermissions() async {
    try {
      // Check current status
      PermissionStatus status = await Permission.location.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        // Request permission with timeout
        final requestFuture = Permission.location.request();
        status = await requestFuture.timeout(Duration(seconds: 3));
        return status.isGranted;
      }

      // If permanently denied or other status
      return false;
    } catch (e) {
      debugPrint('Permission check timeout or error: $e');
      return false;
    }
  }

  /// Convert coordinates to city name with timeout
  Future<String> _getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Add timeout to geocoding as well
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(Duration(seconds: 3));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        String cityName =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            'Unknown Location';

        String country = place.country ?? '';

        if (country.isNotEmpty && cityName != 'Unknown Location') {
          return '$cityName,$country';
        }

        return cityName;
      } else {
        throw Exception('No location information found');
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      // Return coordinates as fallback
      return 'Location (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
    }
  }

  /// Legacy methods for backward compatibility
  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
