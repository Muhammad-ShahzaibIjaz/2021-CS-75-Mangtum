import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangtumcode/Refrences/userRef.dart';
import 'package:mangtumcode/Widgets/drawer.dart';
import 'package:mangtumcode/pages/AddProductPage.dart';
import 'package:mangtumcode/pages/PaymentMethod.dart';
import 'package:mangtumcode/pages/RenderProductPage.dart';
import 'package:mangtumcode/uities/routes.dart';

class RenderHomePage extends StatelessWidget {
  final String userId;

  RenderHomePage({Key? key, String? userId})
      : userId = userId ?? '',
        super(key: key);

  factory RenderHomePage.create({Key? key, String userId = ''}) {
    return RenderHomePage(
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
            title: Text('Render Home Page'),
            backgroundColor: Colors.amber,
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  print(userId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(userId: userId),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.loginRoute);
                },
              ),
              IconButton(
                icon: Icon(Icons.paypal, color: Colors.white),
                onPressed: () {
                  print(userId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentMethodPage(userId: userId),
                    ),
                  );
                },
              ),
            ],
          ),
          drawer: MyDrawer(
            name: userData['name'] ?? 'Name not found',
            email: userData['email'] ?? 'Email not found',
            userId: userId,
          ),
          body: buildProductListView(userId),
        );
      },
    );
  }

  Widget buildProductListView(String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Products')
          .where('userId', isEqualTo: userId)
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
                    // Navigate to another page with detailed product information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RenderProductPage(productId),
                      ),
                    );
                  },
                  child: Container(
                      margin: EdgeInsets.all(8), // Adjust the margin as needed
                      padding:
                          EdgeInsets.all(8), // Adjust the padding as needed
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey), // Add border to the container
                        borderRadius: BorderRadius.circular(
                            8), // Add border radius to the container
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(
                            16), // Adjust the overall padding of the ListTile
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width:
                                  80, // Adjust the width of the image container
                              height:
                                  80, // Adjust the height of the image container
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    8), // Adjust the border radius as needed
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    16), // Adjust the spacing between the image and text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: TextStyle(
                                      fontSize:
                                          18, // Adjust the font size of the product name
                                      fontWeight: FontWeight
                                          .bold, // Adjust the font weight as needed
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
                                  SizedBox(
                                      height:
                                          8), // Adjust the spacing between product name and price
                                  Text(
                                    'Price: \$${productPrice}', // Format the price as needed
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )));
            },
          );
        } else {
          // User has no products
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LET\'S START / ENDL ENTER NEW PRODUCT NOW',
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
