// Packages
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GpsService {
  /// Get current location and city name via reverse geocoding
  /// Returns a city name string, or null if unavailable
  Future<String?> getLocationCityName({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // Check location services enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          debugPrint('Location services disabled');
        }
        return null;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (kDebugMode) {
            debugPrint('Location permission denied');
          }
          return null;
        }
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        timeLimit: timeout,
      );

      // Reverse geocode to get city name
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Try city, then locality, then administrativeArea
        final cityName =
            placemark.locality ?? placemark.administrativeArea ?? 'Unknown';
        return cityName;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting location city: $e');
      }
      return null;
    }
  }
}

