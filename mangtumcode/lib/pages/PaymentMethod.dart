import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentMethodPage extends StatelessWidget {

  final String? userId;

  PaymentMethodPage({Key? key, this.userId}) : super(key: key);


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text('Add Payment Method'),

        backgroundColor: Colors.amber,

      ),

      body: PaymentMethodForm(userId: userId),

    );

  }

}


class PaymentMethodForm extends StatefulWidget {

  final String? userId;


  PaymentMethodForm({Key? key, this.userId}) : super(key: key);


  @override

  _PaymentMethodFormState createState() => _PaymentMethodFormState();

}


class _PaymentMethodFormState extends State<PaymentMethodForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  // Controllers for form fields


  TextEditingController _paypalEmailController = TextEditingController();


  TextEditingController _fullNameController = TextEditingController();


  void _submitForm() {

    if (_formKey.currentState!.validate()) {

      String userId = widget.userId ?? '';


      if (userId.isNotEmpty) {

        DateTime timestampNow = DateTime.now();


        Map<String, dynamic> paymentData = {

          'userId': userId,

          'paypalEmail': _paypalEmailController.text,

          'fullName': _fullNameController.text,

          'status': true,

          'dateUpdated': timestampNow,

        };


        FirebaseFirestore.instance

            .collection('Payment')

            .doc(userId)

            .get()

            .then((documentSnapshot) {

          if (documentSnapshot.exists) {

            paymentData['dateAdded'] = documentSnapshot['dateAdded'];


            documentSnapshot.reference

                .set(

              paymentData,

              SetOptions(merge: true),

            )

                .then((_) {

              _showSnackBar('Payment method data is successfully updated');


              // Navigate or perform other actions as needed

            }).catchError((error) {

              _showSnackBar('Error updating payment method data: $error');

            });

          } else {

            paymentData['dateAdded'] = timestampNow;


            FirebaseFirestore.instance

                .collection('Payment')

                .doc(userId)

                .set(paymentData)

                .then((_) {

              _showSnackBar('Payment method data is successfully saved');

            }).catchError((error) {

              _showSnackBar('Error saving payment method data: $error');

            });

          }

        }).catchError((error) {

          _showSnackBar('Error querying Firestore: $error');

        });

      } else {

        _showSnackBar('userId is empty or null.');

      }

    }

  }


  void _showSnackBar(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(message),

      ),

    );

  }


  @override

  Widget build(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(16.0),

        child: Form(

          key: _formKey,

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              TextFormField(

                controller: _paypalEmailController,

                decoration: InputDecoration(

                  labelText: 'PayPal Email',

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(20.0),

                  ),

                ),

                validator: (value) {

                  if (value!.isEmpty) {

                    return 'Please enter your PayPal email.';

                  }


                  return null;

                },

              ),

              SizedBox(height: 20),

              TextFormField(

                controller: _fullNameController,

                decoration: InputDecoration(

                  labelText: 'Full Name',

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(20.0),

                  ),

                ),

                validator: (value) {

                  if (value!.isEmpty) {

                    return 'Please enter your Full Name.';

                  }


                  return null;

                },

              ),

              SizedBox(height: 20),

              ElevatedButton(

                onPressed: _submitForm,

                child: Text('Submit'),

              ),

            ],

          ),

        ),

      ),

    );

  }

}

