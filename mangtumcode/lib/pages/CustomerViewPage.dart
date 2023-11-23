import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer View'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No users available.'));
            } else {
              return Column(
                children: List.generate(snapshot.data!.docs.length, (index) {
                  var userData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  var userId = snapshot.data!.docs[index].id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('User ID: $userId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${userData['name'] ?? 'N/A'}'),
                            Text('Email: ${userData['email'] ?? 'N/A'}'),
                            Text('Phone: ${userData['phone'] ?? 'N/A'}'),
                            Text('Role: ${userData['role'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                      Divider(), // Add a divider between users for better separation
                    ],
                  );
                }),
              );
            }
          },
        ),
      ),
    );
  }
}
