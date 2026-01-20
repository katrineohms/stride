// Packages
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class GpsService {
  final Location _location = Location();

  Future<bool> isGpsEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    return serviceEnabled;
  }
  
  Future<LocationData?> getLocation() async {
    try {
      // Ensure the service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      // Check permissions
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      return await _location.getLocation();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting location: $e');
      }
      return null;
    }
  }
}
