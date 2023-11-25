import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mangtumcode/pages/BuyerEntryPage.dart';

class UpdateProfilePageBuyer extends StatefulWidget {
  final String userId;

  const UpdateProfilePageBuyer({Key? key, required this.userId})
      : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePageBuyer> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedRole;
  final List<String> roleOptions = ["Admin", "Buyer", "Render"];

  @override
  void initState() {
    super.initState();
    // Fetch user data and populate the form
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      _nameController.text = userData['name'];
      _emailController.text = userData['email'];
      _phoneNumberController.text = userData['phone'];
      _selectedRole = userData['role'];
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneNumberController.text,
          'updated_at': Timestamp.now(),
        });

        // User profile updated successfully
        print('User profile updated: ${widget.userId}');

        // Navigate back to the previous screen or perform other actions
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle update error
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyerEntryPage(userId: widget.userId),
              ),
            );
          },
        ),
      ),
      body: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Name",
                      labelText: "Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      } else if (!value.contains('@')) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_android_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      } else if (!value.startsWith("03") ||
                          value.length != 11) {
                        return "Enter a valid phone number starting with '03' and having a total of 11 characters";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DropdownButtonFormField(
                    value: _selectedRole,
                    onChanged: (newValue) {
                      // Don't allow the user to change the role
                    },
                    items: roleOptions.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: "Role",
                      labelText: "Role",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.query_stats_outlined),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () {
                    updateProfile();
                  },
                  child: Container(
                    width: 150,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      "Update Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
