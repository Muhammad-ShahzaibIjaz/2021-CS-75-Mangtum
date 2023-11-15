import 'package:cloud_firestore/cloud_firestore.dart';

// Replace 'user_document_id' with the actual user document ID
//final userDocumentRef = firestore.collection('Users').doc('user_document_id');
// Access the "Role" collection
final userRoleAdmin = firestore.collection('Role').doc('txuIc1v4zYAEUkzUrX2Q');
final userRoleRender = firestore.collection('Role').doc('cbN301vXDGtepyvlENL2');
final userRoleBuyer = firestore.collection('Role').doc('3eguB3dPzRvoGGc95kHr');
final FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<String?> getUserRoleFromFirestore(String userUid) async {
  try {
    // Reference to the Firestore collection where user data is stored
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Reference to the user's document using userUid
    final DocumentReference userDocRef = usersCollection.doc(userUid);

    // Fetch the user's document
    final DocumentSnapshot userDoc = await userDocRef.get();

    // Check if the document exists
    if (userDoc.exists) {
      // Get the 'role' field from the user's document, which is a reference to a role document
      final DocumentReference roleReference = userDoc.get('role');

      // Fetch the role document
      final DocumentSnapshot roleDoc = await roleReference.get();

      // Check if the role document exists and return the role name
      if (roleDoc.exists) {
        final String? roleName = roleDoc.get(
            'name'); // Replace 'name' with the actual field name in the role document that holds the role name.
        return roleName;
      }
    }

    // Return null if the user's role document does not exist or if 'role' is not found
    return null;
  } catch (e) {
    // Handle any errors that occur during the Firestore query
    print('Error getting user role: $e');
    return null;
  }
}
