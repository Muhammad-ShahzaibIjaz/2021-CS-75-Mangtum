import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangtumcode/Widgets/drawer.dart';
import 'package:mangtumcode/pages/AddProductPage.dart';
import 'package:mangtumcode/pages/PaymentMethod.dart';
import 'package:mangtumcode/pages/RenderProductPage.dart';
import 'package:mangtumcode/uities/routes.dart';

class RenderHomePage extends StatefulWidget {
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
  _RenderHomePageState createState() => _RenderHomePageState();
}

class _RenderHomePageState extends State<RenderHomePage> {
  late TextEditingController _searchController;

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
          body: Column(
            children: [
              buildSearchBar(),
              Expanded(
                child: buildProductListView(userId),
              ),
            ],
          ),
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
          List<DocumentSnapshot> filteredProducts = snapshot.data!.docs
              .where((product) => product['productName']
                  .toString()
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();

          if (filteredProducts.isNotEmpty) {
            return ListView.builder(
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
                        )));
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

  Widget buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildNoProductsFoundScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LET\'S START / ENDL ENTER NEW PRODUCT NOW',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
