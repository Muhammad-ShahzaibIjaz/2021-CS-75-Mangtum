import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RenderProductPage extends StatefulWidget {
  final String productId;

  RenderProductPage(this.productId);

  @override
  _RenderProductPageState createState() => _RenderProductPageState();
}

class _RenderProductPageState extends State<RenderProductPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _thresholdController = TextEditingController();
  String? _imageUrl;

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
        title: Text(
          'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: _imageUrl != null && _imageUrl!.isNotEmpty
                    ? Image.network(_imageUrl!, height: 200, width: 200)
                    : Text('Image not available'),
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 16),
            ],
          ),
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
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Set the desired background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.amber, // Set the desired icon color
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                _updateProduct();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Set the desired background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.save,
                    color: Colors.amber, // Set the desired icon color
                  ),
                ),
              ),
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
