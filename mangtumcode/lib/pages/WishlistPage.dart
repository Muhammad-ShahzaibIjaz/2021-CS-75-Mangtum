import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';


import 'package:mangtumcode/pages/BuyerEntryPage.dart';


class WishlistPage extends StatelessWidget {

  final String userId;


  WishlistPage(this.userId);


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: Icon(Icons.arrow_back),

          onPressed: () {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (context) => BuyerEntryPage(

                  userId: userId,

                ),

              ),

            );

          },

        ),

        title: Text(

          'Wishlist',

          style: TextStyle(color: Colors.white),

        ),

        backgroundColor: Colors.amber,

      ),

      body: buildProductListView(userId),

    );

  }


  Widget buildProductListView(String userId) {

    return FutureBuilder<QuerySnapshot>(

      future: FirebaseFirestore.instance

          .collection('Wishlist')

          .where('userId', isEqualTo: userId)

          .get(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return Center(child: CircularProgressIndicator());

        } else if (snapshot.hasError) {

          return Center(child: Text('Error: ${snapshot.error}'));

        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {

          return ListView.builder(

            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final productData = snapshot.data!.docs[index];


              final productId = productData['productId'];


              bool isWishlist = productData['isWishlist'] ?? false;


              return FutureBuilder<DocumentSnapshot>(

                future: FirebaseFirestore.instance

                    .collection('Products')

                    .doc(productId)

                    .get(),

                builder: (context, productSnapshot) {

                  if (productSnapshot.connectionState ==

                      ConnectionState.waiting) {

                    return SizedBox

                        .shrink(); // You can show a loading indicator here

                  } else if (productSnapshot.hasError) {

                    return Text('Error: ${productSnapshot.error}');

                  } else if (productSnapshot.hasData) {

                    final productDetails = productSnapshot.data!;


                    final productName =

                        productDetails['productName'] ?? 'Product Name N/A';


                    final productPrice =

                        productDetails['price']?.toString() ?? 'Price N/A';


                    final imageUrl = productDetails['imageUrl'] ?? '';


                    final productDescription =

                        productDetails['description'] ?? '';


                    return Container(

                      margin: EdgeInsets.all(8),

                      padding: EdgeInsets.all(8),

                      decoration: BoxDecoration(

                        border: Border.all(color: Colors.grey),

                        borderRadius: BorderRadius.circular(8),

                      ),

                      child: Column(

                        children: [

                          ListTile(

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

                                SizedBox(width: 8),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:

                                        CrossAxisAlignment.start,

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

                          Row(

                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [

                              IconButton(

                                onPressed: () {

                                  // Toggle the wishlist status


                                  isWishlist = !isWishlist;


                                  // Update the wishlist status in Firestore


                                  FirebaseFirestore.instance

                                      .collection('Wishlist')

                                      .doc('${userId}_${productId}')

                                      .update({

                                    'isWishlist': isWishlist,

                                  });

                                },

                                icon: Icon(

                                  isWishlist

                                      ? Icons.favorite

                                      : Icons.favorite_border,

                                  color: isWishlist ? Colors.amber : null,

                                ),

                              ),

                            ],

                          ),

                        ],

                      ),

                    );

                  } else {

                    return SizedBox

                        .shrink(); // Return an empty widget if no data is available

                  }

                },

              );

            },

          );

        } else {

          return Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Text(

                  'No Wishlist Products',

                  style: TextStyle(fontSize: 18),

                ),

              ],

            ),

          );

        }

      },

    );

  }

}

