import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlert {
  final String id;
  final String message;
  final Timestamp timestamp;
  final String severity;
  final bool isActive;

  EmergencyAlert({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.severity,
    required this.isActive,
  });

  factory EmergencyAlert.fromMap(Map<String, dynamic> map, String documentId) {
    return EmergencyAlert(
      id: documentId,
      message: map['message'] ?? '',
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      severity: map['severity'] ?? 'medium',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'severity': severity,
      'isActive': isActive,
      'timestamp': timestamp,
    };
  }

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'high',
      isActive: json['isActive'] as bool? ?? true,
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
