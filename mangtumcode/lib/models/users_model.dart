import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? name;
  String? userEmail;
  String? userPassword;
  String? userPhone;
  bool isActive;
  Timestamp created_at;
  Timestamp updated_at;
  DocumentReference? userRole;
  Users({
    required this.name,
    required this.userEmail,
    required this.userPassword,
    required this.userPhone,
    bool? isActive,
    Timestamp? created_at,
    Timestamp? updated_at,
    required this.userRole,
  })  : this.isActive = isActive ?? true,
        this.created_at = created_at ?? Timestamp.now(),
        this.updated_at = updated_at ?? Timestamp.now();
  toJson() {
    return {
      'Name': name,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'userPhone': userPhone,
      'isActive': isActive,
      'created_at': created_at,
      'updated_at': updated_at,
      'userRole': userRole,
    };
  }
}
