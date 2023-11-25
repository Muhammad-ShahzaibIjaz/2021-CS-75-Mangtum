import 'package:flutter/material.dart';


import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/services.dart';


import 'package:mangtumcode/models/cartItem.dart';


class CartPage extends StatefulWidget {

  final String userId;


  CartPage({required this.userId});


  @override

  _CartPageState createState() => _CartPageState();

}


class _CartPageState extends State<CartPage> {

  List<CartItem> cartItems = [];


  @override

  void initState() {

    super.initState();


    _loadCartItems();

  }


  void _loadCartItems() async {

    CartService.fetchCartItems(widget.userId).then((items) {
      // Use the items list here
      for (CartItem item in items) {
        print(item.productId);
        print(item.productName);
        print(item.productPrice);
        print(item.productImageUrl);
        print(item.quantity);
      }
    });

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text('Shopping Cart'),

        backgroundColor: Colors.amber,

      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              itemCount: cartItems.length,

              itemBuilder: (context, index) {

                return Container(

                  margin: EdgeInsets.all(8.0),

                  padding: EdgeInsets.all(8.0),

                  decoration: BoxDecoration(

                    border: Border.all(color: Colors.grey),

                    borderRadius: BorderRadius.circular(8.0),

                  ),

                  child: CartItemWidget(

                    cartItem: cartItems[index],

                    onQuantityChanged: _updateTotal,

                  ),

                );

              },

            ),

          ),

          Container(

            color: Colors.amber,

            child: ListTile(

              title: Text(

                'Total: \$${_calculateTotal()}',

                style: TextStyle(color: Colors.white),

              ),

              trailing: ElevatedButton(

                onPressed: () {

                  // Implement your checkout logic here


                  _confirmCheckout();

                },

                child: Text('Checkout'),

              ),

            ),

          ),

        ],

      ),

    );

  }


  double _calculateTotal() {

    double total = 0;


    for (var item in cartItems) {

      // Ensure that quantity is at least 1


      int quantity = item.quantity <= 0 ? 1 : item.quantity;


      total += quantity * item.productPrice;

    }


    return total;

  }


  void _updateTotal() {

    setState(() {

      // Update the total when the quantity changes

    });

  }


  void _confirmCheckout() {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          title: Text('Confirm Checkout'),

          content: Text('Are you sure you want to proceed with the checkout?'),

          actions: <Widget>[

            TextButton(

              onPressed: () {

                Navigator.of(context).pop(); // Close the dialog

              },

              child: Text('Cancel'),

            ),

            TextButton(

              onPressed: () {

                Navigator.of(context).pop(); // Close the dialog


                _checkout();

              },

              child: Text('Proceed'),

            ),

          ],

        );

      },

    );

  }


  Future<void> _updateProductQuantities(List<CartItem> cartItems) async {

    for (var item in cartItems) {

      await FirebaseFirestore.instance

          .collection('Products')

          .doc(item.productId)

          .update({'quantity': FieldValue.increment(-item.quantity)});

    }

  }


  Future<void> _showBillDialog(List<CartItem> cartItems, double total) async {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          title: Text('Bill Details'),

          content: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisSize: MainAxisSize.min,

            children: [

              for (var item in cartItems)

                Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text('Product: ${item.productName}'),

                    Text('Price: \$${item.productPrice}'),

                    Text('Quantity: ${item.quantity}'),

                    Divider(),

                  ],

                ),

              Text('Total: \$${total}'),

            ],

          ),

          actions: <Widget>[

            TextButton(

              onPressed: () {

                Navigator.of(context).pop(); // Close the dialog

              },

              child: Text('Close'),

            ),

          ],

        );

      },

    );

  }


  Future<void> _saveOrderHistory(List<CartItem> cartItems, double total) async {

    try {

      final historyRef = FirebaseFirestore.instance.collection('OrderHistory');


      await historyRef.add({

        'userId': widget.userId,

        'cartItems': cartItems.map((item) => item.toMap()).toList(),

        'totalAmount': total,

        'created_at': FieldValue.serverTimestamp(),

      });

    } catch (e) {

      print('Error saving order history: $e');


      // Handle the error accordingly.

    }

  }


  Future<String?> getUserEmailFromUserId(String userId) async {

    try {

      // Assuming you have a Firestore collection named 'users'


      // with documents containing 'userId' and 'email' fields


      var userDoc = await FirebaseFirestore.instance

          .collection('Users')

          .doc(userId)

          .get();


      if (userDoc.exists) {

        return userDoc.data()?['email'];

      } else {

        print('User document not found for userId: $userId');


        return null;

      }

    } catch (e) {

      print('Error retrieving user email: $e');


      return null;

    }

  }


  void _checkout() async {

    try {

      // 3. Save Order History


      await _saveOrderHistory(cartItems, _calculateTotal());


      // 2. Update Product Quantities


      await _updateProductQuantities(cartItems);


      // 4. Remove items from the cart


      await _deleteAllCartItems(widget.userId);


      // 1. Generate Bill Report


      await _showBillDialog(cartItems, _calculateTotal());


      // Optionally, you can navigate to a success page or show a success message.

    } catch (e) {

      print('Error during checkout: $e');


      // Handle errors, show an error message, or roll back changes if necessary.

    }

  }


  Future<void> _deleteAllCartItems(String userId) async {

    try {

      QuerySnapshot<Map<String, dynamic>> cartSnapshot = await FirebaseFirestore

          .instance

          .collection('Cart')

          .where('userId', isEqualTo: userId)

          .get();


      for (QueryDocumentSnapshot<Map<String, dynamic>> cartDoc

          in cartSnapshot.docs) {

        await cartDoc.reference.delete();

      }


      // Clear the cartItems list


      setState(() {

        cartItems = [];

      });


      print('All cart items for user $userId deleted successfully.');

    } catch (e) {

      print('Error deleting cart items: $e');


      // Handle errors, show an error message, or roll back changes if necessary.

    }

  }

}


class CartItemWidget extends StatefulWidget {

  final CartItem cartItem;


  final VoidCallback onQuantityChanged;


  CartItemWidget({

    required this.cartItem,

    required this.onQuantityChanged,

  });


  @override

  _CartItemWidgetState createState() => _CartItemWidgetState();

}


class _CartItemWidgetState extends State<CartItemWidget> {

  @override

  Widget build(BuildContext context) {

    return ListTile(

      leading: Image.network(

        widget.cartItem.productImageUrl,

        width: 50,

        height: 50,

        fit: BoxFit.cover,

      ),

      title: Text(widget.cartItem.productName),

      subtitle: Text('Price: \$${widget.cartItem.productPrice}'),

      trailing: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          IconButton(

            icon: Icon(Icons.remove),

            onPressed: () {

              setState(() {

                if (widget.cartItem.quantity > 1) {

                  widget.cartItem.quantity--;


                  widget.onQuantityChanged();

                }

              });

            },

          ),

          Text(widget.cartItem.quantity.toString()),

          IconButton(

            icon: Icon(Icons.add),

            onPressed: () {

              setState(() {

                widget.cartItem.quantity++;


                widget.onQuantityChanged();

              });

            },

          ),

        ],

      ),

    );

  }

}

