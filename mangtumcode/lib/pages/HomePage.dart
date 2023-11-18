import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangtumcode/Refrences/userRef.dart';
import 'package:mangtumcode/Widgets/MyDrawerBuyer.dart';
import 'package:mangtumcode/pages/CartPage.dart';
import 'package:mangtumcode/pages/ProductDetailPage.dart';
import 'package:mangtumcode/pages/WishlistPage.dart';

class HomePage extends StatelessWidget {
  final String userId;

  HomePage({Key? key, String? userId})
      : userId = userId ?? '',
        super(key: key);

  factory HomePage.create({Key? key, String userId = ''}) {
    return HomePage(
      key: key,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // Check if args is not null before accessing userId
    final userId = args?['userId'];
    return FutureBuilder<Map<String, dynamic>?>(
      future: getNameAndEmailByUidSync(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, you can show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          // Handle errors or when data is not available
          return Center(child: Text('Error fetching user data'));
        }

        final userData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(userId: userId),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WishlistPage(userId),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.login),
              ),
            ],
            title: Text(
              "Mangtum",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: buildProductListView(userId),
          drawer: MyDrawerBuyer(
            name: userData['name'] ?? 'Name not found',
            email: userData['email'] ?? 'Email not found',
            userId: userId,
          ),
        );
      },
    );
  }

  Widget buildProductListView(String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Products')
          .where('isActive', isEqualTo: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // User has products
          // Build and return a widget to display the products here
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              final productId = productData.id;
              final productName = productData['productName'];
              final productPrice = productData['price'].toString();
              final imageUrl = productData['imageUrl'];
              final productDescription = productData['description'];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(productId, userId),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                productDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Price: \$${productPrice}',
                                style: TextStyle(color: Colors.amber),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          // User has no products
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Store Empty',
                  style: TextStyle(fontSize: 18),
                ),
                // Add any other widgets or buttons as needed
              ],
            ),
          );
        }
      },
    );
  }
}
