import 'package:flutter/material.dart';
import 'package:mangtumcode/Refrences/userRef.dart';
import 'package:mangtumcode/Widgets/MyDrawerAdmin.dart';
import 'package:mangtumcode/uities/routes.dart';

class AdminDashboardPage extends StatelessWidget {
  final String userId;

  AdminDashboardPage({Key? key, String? userId})
      : userId = userId ?? '',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userId = args?['userId'];
    return FutureBuilder<Map<String, dynamic>?>(
        future: getNameAndEmailByUidSync(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching user data'));
          }
          final userData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Admin Panel',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.amber,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, MyRoutes.loginRoute);
                  },
                ),
              ],
            ),
            drawer: MyDrawerAdmin(
              name: userData['name'] ?? 'Name not found',
              email: userData['email'] ?? 'Email not found',
              userId: userId,
            ),
            body: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'Assets/images/MangtumLogo.png',
                      width: 250.0, // Adjust the width as needed
                      height: 150.0, // Adjust the height as needed
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'User Name: ${userData['name'] ?? 'Name not found'}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      'User Email: ${userData['email'] ?? 'Email not found'}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
