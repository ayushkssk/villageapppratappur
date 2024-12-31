import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? lastUpdated;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.lastUpdated,
  });

  factory UserModel.fromFirebaseUser(String uid, String email) {
    return UserModel(
      uid: uid,
      email: email,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  UserModel copyWith({
    String? name,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastUpdated,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get displayNameOrEmail => name ?? displayName ?? email.split('@')[0];
}
