import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangtumcode/pages/RenderProductPage.dart';
import 'package:mangtumcode/uities/routes.dart';

class RenderHomePage extends StatefulWidget {
  final String userId;

  RenderHomePage({Key? key, required String userId})
      : userId = userId,
        super(key: key);

  factory RenderHomePage.create({Key? key, required String userId}) {
    return RenderHomePage(
      key: key,
      userId: userId,
    );
  }

  @override
  _RenderHomePageState createState() => _RenderHomePageState();
}

class _RenderHomePageState extends State<RenderHomePage> {
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('MyProduct', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(
              context,
              MyRoutes.RenderEntryPage,
              arguments: {'userId': widget.userId}, // Pass the userId here
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProductListView(widget.userId),
          ],
        ),
      ),
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
          List<DocumentSnapshot> filteredProducts = snapshot.data!.docs;

          if (filteredProducts.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final productData = filteredProducts[index];
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
                        builder: (context) => RenderProductPage(productId),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width / 2,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              productName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '\$${productPrice}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          productDescription,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return _buildNoProductsFoundScreen();
          }
        } else {
          return _buildNoProductsFoundScreen();
        }
      },
    );
  }

  Widget _buildNoProductsFoundScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No properties found.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
