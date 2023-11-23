import 'package:cloud_firestore/cloud_firestore.dart';

class ExceptionLogger {
  static void logError({
    required String functionName,
    required dynamic error,
    required StackTrace stackTrace,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Exception_Logs').add({
        'functionName': functionName,
        'timestamp': FieldValue.serverTimestamp(),
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
    } catch (e) {
      print('Error logging exception: $e');
    }
  }
}
