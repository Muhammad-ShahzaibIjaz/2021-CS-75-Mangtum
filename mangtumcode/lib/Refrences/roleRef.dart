import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
// Replace 'user_document_id' with the actual user document ID
final userDocumentRef = firestore.collection('Users').doc('user_document_id');
// Access the "Role" subcollection within the user document
final userRoleAdmin =
    userDocumentRef.collection('Role').doc('NVnM96hSI3L6xbkI5oAS');
final userRoleRender =
    userDocumentRef.collection('Role').doc('uAvTsmYUqDj0Buxe144N');
final userRoleBuyer =
    userDocumentRef.collection('Role').doc('Zs4m926a1mchbejTuqXj');

Future<String?> getUserRoleDocIdFromFirestore(String userUid) async {
  try {
    // Reference to the Firestore collection where user data is stored
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Query for the user document by UID
    final DocumentSnapshot userDoc = await usersCollection.doc(userUid).get();

    // Check if the user document exists and contains a 'userRole' field
    if (userDoc.exists && userDoc.data() != null) {
      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      // Check if the 'userRole' field exists and is a string
      if (userData.containsKey('userRole') && userData['userRole'] is String) {
        return userData['userRole'] as String;
      }
    }

    // Return null if the user document or 'userRole' field is not found
    return null;
  } catch (e) {
    // Handle any errors that occur during the Firestore query
    print('Error getting user role: $e');
    return null;
  }
}
