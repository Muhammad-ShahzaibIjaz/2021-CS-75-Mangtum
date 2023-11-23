import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangtumcode/pages/AddProductPage.dart';
import 'package:mangtumcode/pages/OrderViewRender.dart';
import 'package:mangtumcode/pages/PaymentMethod.dart';
import 'package:mangtumcode/pages/RenderHomePage.dart';
import 'package:mangtumcode/pages/ThresholdViewPage.dart';
import 'package:mangtumcode/pages/UpadteProfilePage.dart';

class RenderEntryPage extends StatefulWidget {
  final String userId;

  RenderEntryPage({Key? key, String? userId})
      : userId = userId ?? '',
        super(key: key);

  factory RenderEntryPage.create({Key? key, String userId = ''}) {
    return RenderEntryPage(
      key: key,
      userId: userId,
    );
  }

  @override
  _RenderEntryPageState createState() => _RenderEntryPageState();
}

class _RenderEntryPageState extends State<RenderEntryPage> {
  late String userEmail;
  late String userName;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>?> getNameAndEmailByUidSync(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return null;
    }
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(userId)
          .get();
      return userDoc.data();
    } catch (e) {
      print('Error getting name and email by UID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = args?['userId'];
    return FutureBuilder<Map<String, dynamic>?>(
      future: getNameAndEmailByUidSync(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.amber));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error fetching user data'));
        }
        final userData = snapshot.data!;
        userEmail = userData['email'] ?? 'Email not found';
        userName = userData['name'] ?? 'Name not found';
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar and user information
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.amber,
                      // ignore: unnecessary_null_comparison
                      child: Text(userName != null ? userName[0] : '',
                          style: TextStyle(fontSize: 20)),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.black),
                      onPressed: () {
                        // Add your logout logic here
                        // For example, navigate to the login page
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                // Containers for different actions
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RenderHomePage(userId: userId)),
                    );

                    print('Your Products clicked!');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Products',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'View and manage your products',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddProductPage(userId: userId)),
                    );
                    print('Addition of the Product clicked!');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 218, 167, 15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Addition of the Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Add Your Products',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RenderOrderViewPage(userId: userId)),
                    );
                    print('Sales of the Product clicked!');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales of the Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Track your product sales',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ThresholdViewPage(userId: userId)),
                    );
                    print('Threshold handle clicked!');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Threshold handle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Adjust product threshold settings',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(), // Add Divider here
                Spacer(),
                // Icons at the bottom for home and profile navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, size: 30),
                      onPressed: () {
                        print('Home icon clicked!');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person, size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UpdateProfilePage(userId: userId)),
                        );
                        print('Profile icon clicked!');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.payment_outlined, size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PaymentMethodPage(userId: userId)),
                        );
                        print('Payment icon clicked!');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
