import 'package:flutter/material.dart';
import '../../model/clients.dart';

/// ViewModel for managing appointment form state and logic
class AppointmentFormViewModel {
  final List<Appointment> _appointments = [];

  // ===== Getters =====
  List<Appointment> get appointments => List.from(_appointments);

  // ===== Initialization =====
  void initialize(List<Appointment> initialAppointments) {
    _appointments.clear();
    _appointments.addAll(initialAppointments);
  }

  // ===== CRUD Operations =====
  /// Add a new appointment from picked date and time
  Appointment createAppointment(DateTime pickedDate, TimeOfDay pickedTime) {
    final timestamp = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ).millisecondsSinceEpoch ~/ 1000;

    return Appointment(timestamp: timestamp);
  }

  /// Add appointment to list
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  /// Remove appointment from list
  void removeAppointment(Appointment appointment) {
    _appointments.remove(appointment);
  }

  // ===== Formatting =====
  /// Format timestamp to readable string (YYYY-MM-DD HH:MM)
  String formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ===== Validation =====
  String? validateAppointments() {
    if (_appointments.isEmpty) return 'Pick at least one appointment';
    return null;
  }

  bool hasAppointments() => _appointments.isNotEmpty;
}
