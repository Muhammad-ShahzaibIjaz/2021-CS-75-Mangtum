import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductPage extends StatelessWidget {
  final String? userId;
  AddProductPage({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<String?>(
        future: getPaymentId(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Display a loading indicator.
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle errors if any.
          } else {
            final paymentId = snapshot.data;

            if (paymentId != null) {
              print("PaymentID=$paymentId");
              // User has payment information.
              return AddProductForm(userId: userId, paymentId: paymentId);
            } else {
              // User doesn't have payment information.
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Please add payment information before adding a product.'),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Add Payment page.
                      Navigator.pushNamed(context, '/add_payment');
                    },
                    child: Text('Add Payment'),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }

  Future<String?> getPaymentId(String? userId) async {
    try {
      final QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('Payment')
          .where('userId', isEqualTo: userId)
          .get();

      if (paymentSnapshot.docs.isNotEmpty) {
        // Get the first document ID from the QuerySnapshot
        final String paymentId = paymentSnapshot.docs[0].id;
        return paymentId;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting payment information: $e');
      return null;
    }
  }
}

class AddProductForm extends StatefulWidget {
  final String? userId;
  final String? paymentId;

  AddProductForm({Key? key, this.userId, this.paymentId}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _thresholdController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isActive = true; // Default value for active

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Icon(
                Icons.add_a_photo,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Add a new product',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.title_sharp)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product name.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.description_sharp)),
                maxLines: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product description.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: 'Price (\$)',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.price_change_sharp)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product price.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.confirmation_number_sharp)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product quantity.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _thresholdController,
                decoration: InputDecoration(
                    labelText: 'Threshold',
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.production_quantity_limits)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product threshold.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, height: 100, width: 100)
                    : Container(
                        color: Colors.grey[300],
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Text('Tap to pick an image'),
                        ),
                      ),
              ),
              Row(
                children: <Widget>[
                  Text('Active: '),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    hoverColor: Colors.amber,
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final String productName = _productNameController.text;
                    final String description = _descriptionController.text;
                    final double price = double.parse(_priceController.text);
                    final int quantity = int.parse(_quantityController.text);
                    final int threshold = int.parse(_thresholdController.text);
                    final bool isActive = _isActive;

                    if (_imageBytes != null) {
                      // Upload the image to Firebase Storage and get the download URL
                      uploadImageToStorage(_imageBytes!).then((imageUrl) {
                        _addProductToFirestore(
                          widget.userId!, // Pass the userId from the widget
                          productName,
                          description,
                          price,
                          quantity,
                          threshold,
                          isActive,
                          imageUrl,
                        );
                      });
                    } else {
                      // Handle the case when no image is selected
                      print('Please select an image for the product.');
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print("PAATH");
      print(image.path);
      // final File mediaFile = File(image.path);
      // final Uint8List imageBytes = await mediaFile.readAsBytes();
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    } else {
      // Handle unsupported image format
      print('Unsupported image format. Please select a valid image.');
    }
  }

  Future<void> _addProductToFirestore(
    String userId,
    String productName,
    String description,
    double price,
    int quantity,
    int threshold,
    bool isActive,
    String imageUrl,
  ) async {
    try {
      final CollectionReference productsCollection =
          FirebaseFirestore.instance.collection('Products');

      final Timestamp currentTime = Timestamp.now();

      await productsCollection.add({
        'userId': userId,
        'productName': productName,
        'description': description,
        'price': price,
        'quantity': quantity,
        'threshold': threshold,
        'isActive': isActive,
        'imageUrl': imageUrl,
        'createdAt': currentTime,
        'updatedAt': currentTime,
      });

      print('Product added to Firestore');
    } catch (e) {
      print('Error adding product to Firestore: $e');
    }
  }

  Future<String> uploadImageToStorage(Uint8List bytes) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;

      // Create a unique filename for the image (e.g., using a timestamp)
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to the Firebase Storage location
      final Reference reference =
          storage.ref().child('product_images/$fileName.jpg');

      // Upload the image to Firebase Storage
      final TaskSnapshot storageTaskSnapshot = await reference.putData(bytes);

      if (storageTaskSnapshot.state == TaskState.success) {
        final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
        return imageUrl;
      } else {
        // Handle errors or return a default URL
        return 'Error uploading image';
      }
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return 'Error uploading image';
    }
  }
}
