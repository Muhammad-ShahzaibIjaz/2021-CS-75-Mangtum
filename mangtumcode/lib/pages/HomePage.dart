import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';


import 'package:mangtumcode/pages/BuyerEntryPage.dart';


import 'package:mangtumcode/pages/CartPage.dart';


import 'package:mangtumcode/pages/ProductDetailPage.dart';


import 'package:mangtumcode/pages/WishlistPage.dart';


class HomePage extends StatefulWidget {

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

  _HomePageState createState() => _HomePageState();

}


class _HomePageState extends State<HomePage> {

  late TextEditingController _searchController;


  List<DocumentSnapshot> _filteredProducts = [];


  @override

  void initState() {

    super.initState();


    _searchController = TextEditingController();

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

    return FutureBuilder<Map<String, dynamic>?>(

      future: getNameAndEmailByUidSync(widget.userId),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return _buildLoadingScreen();

        } else if (snapshot.hasError || !snapshot.hasData) {

          return _buildErrorScreen();

        }

        // ignore: unused_local_variable
        final userData = snapshot.data!;

        return Scaffold(

          appBar: AppBar(

            leading: IconButton(

              icon: Icon(Icons.arrow_back),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) => BuyerEntryPage(

                      userId: widget.userId,

                    ),

                  ),

                );

              },

            ),

            actions: [

              IconButton(

                onPressed: () async {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (context) => CartPage(userId: widget.userId),

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

                      builder: (context) => WishlistPage(widget.userId),

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

          body: Column(

            children: [

              buildSearchBar(),

              Expanded(

                child: buildProductListViewStream(widget.userId),

              ),

            ],

          ),

        );

      },

    );

  }


  Widget buildProductListViewStream(String userId) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance

          .collection('Products')

          .where('isActive', isEqualTo: true)

          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return _buildLoadingScreen();

        }


        final products = snapshot.data?.docs ?? [];


        _filteredProducts = products

            .where((product) => product['productName']

                .toString()

                .toLowerCase()

                .contains(_searchController.text.toLowerCase()))

            .toList();


        if (_filteredProducts.isEmpty) {

          return _buildNoProductsFoundScreen();

        }


        return ListView.builder(

          itemCount: _filteredProducts.length,

          itemBuilder: (context, index) {

            final productData = _filteredProducts[index];


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

                    builder: (context) => ProductDetailPage(productId, userId),

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

      },

    );

  }


  Widget buildSearchBar() {

    return Container(

      padding: EdgeInsets.all(10),

      child: TextField(

        controller: _searchController,

        onChanged: (value) {

          setState(() {});

        },

        decoration: InputDecoration(

          hintText: 'Search',

          border: OutlineInputBorder(),

          prefixIcon: Icon(Icons.search),

        ),

      ),

    );

  }


  Widget _buildLoadingScreen() {

    return Center(

      child: CircularProgressIndicator(),

    );

  }


  Widget _buildNoProductsFoundScreen() {

    return Center(

      child: Text('No products found.'),

    );

  }


  Widget _buildErrorScreen() {

    return Center(

      child: Text('Error fetching data.'),

    );

  }

}

