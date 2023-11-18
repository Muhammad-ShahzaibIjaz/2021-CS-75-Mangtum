import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenderProductPage extends StatefulWidget {
  final String productId;

  RenderProductPage(this.productId);

  @override
  _RenderProductPageState createState() => _RenderProductPageState();
}

class _RenderProductPageState extends State<RenderProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _thresholdController;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() async {
    // Retrieve product details based on productId
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.productId)
        .get();

    // Populate the form fields with retrieved data
    setState(() {
      _nameController =
          TextEditingController(text: productSnapshot['productName']);
      _descriptionController =
          TextEditingController(text: productSnapshot['description']);
      _priceController =
          TextEditingController(text: productSnapshot['price'].toString());
      _quantityController =
          TextEditingController(text: productSnapshot['quantity'].toString());
      _thresholdController =
          TextEditingController(text: productSnapshot['threshold'].toString());
      _imageUrl = productSnapshot['imageUrl'];
    });
  }

  void _updateProduct() async {
    // Perform the update operation in Firebase
    await FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.productId)
        .update({
      'productName': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'quantity': int.parse(_quantityController.text),
      'threshold': int.parse(_thresholdController.text),
      'updatedAt': DateTime.now(),
    });

    // Notify the user that the update was successful
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product updated successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(_imageUrl, height: 200, width: 200),
            SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _thresholdController,
              decoration: InputDecoration(
                labelText: 'Threshold',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // Add logic to delete the product here
                _deleteProduct();
              },
              child: Icon(Icons.delete),
              backgroundColor: Colors.amber,
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                _updateProduct();
              },
              child: Icon(Icons.save),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct() async {
    // Add logic to delete the product in Firebase
    await FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.productId)
        .delete();
    Navigator.pop(context);
  }
}
