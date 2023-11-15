import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mangtumcode/models/cartItem.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:google_fonts/google_fonts.dart' as fonts;

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
    QuerySnapshot<Map<String, dynamic>> cartSnapshot = await FirebaseFirestore
        .instance
        .collection('Cart')
        .where('userId', isEqualTo: widget.userId)
        .get();

    List<CartItem> items = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> cartDoc
        in cartSnapshot.docs) {
      // Fetch product details from the Products collection
      DocumentSnapshot<Map<String, dynamic>> productDoc =
          await FirebaseFirestore.instance
              .collection('Products')
              .doc(cartDoc['productId'])
              .get();

      // Check if the product exists in the Products collection
      if (productDoc.exists) {
        // Create a CartItem object
        CartItem item = CartItem.fromSnapshot(cartDoc, productDoc);

        // Add the item to the list
        items.add(item);
      }
    }

    setState(() {
      cartItems = items;
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

  void _checkout() async {
    try {
      // 1. Generate Bill Report
      //await _generateBillReport(cartItems, _calculateTotal());
      // 2. Update Product Quantities
      await _updateProductQuantities(cartItems);

      // Optionally, you can navigate to a success page or show a success message.
    } catch (e) {
      print('Error during checkout: $e');
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
