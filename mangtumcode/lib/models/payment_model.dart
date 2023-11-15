// payment_method.dart
class PaymentMethod {
  final String userId;
  final String paypalEmail;
  final String fullName;
  final String status;
  final DateTime dateAdded;
  final DateTime dateUpdated;
  final Map<String, dynamic> verificationData;

  PaymentMethod({
    required this.userId,
    required this.paypalEmail,
    required this.fullName,
    required this.status,
    required this.dateAdded,
    required this.dateUpdated,
    required this.verificationData,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> data) {
    return PaymentMethod(
      userId: data['userId'],
      paypalEmail: data['paypalEmail'],
      fullName: data['fullName'],
      status: data['status'],
      dateAdded: data['dateAdded'],
      dateUpdated: data['dateUpdated'],
      verificationData: data['verificationData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'paypalEmail': paypalEmail,
      'fullName': fullName,
      'status': status,
      'dateAdded': dateAdded,
      'dateUpdated': dateUpdated,
      'verificationData': verificationData,
    };
  }
}
