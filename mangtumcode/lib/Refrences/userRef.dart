import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getNameAndEmailByUidSync(String userUid) async {
  try {
    // Reference to the Firestore collection where user data is stored
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Reference to the user's document using userUid
    final DocumentReference userDocRef = usersCollection.doc(userUid);

    // Fetch the user's document and await the result
    final DocumentSnapshot userDoc = await userDocRef.get();

    // Check if the document exists
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final name = userData[
          'name']; // Replace 'name' with the actual field name for the name.
      final email = userData[
          'email']; // Replace 'email' with the actual field name for the email.

      // Create a map with name and email and return it
      return {'name': name, 'email': email};
    }

    // Return null if the user's document does not exist
    return null;
  } catch (e) {
    // Handle any errors that occur during the Firestore query
    print('Error getting name and email by UID: $e');
    return null;
  }
}
