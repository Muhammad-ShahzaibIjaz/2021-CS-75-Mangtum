import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/models/users_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  createUser(Users user) async {
    print("done");
    _db
        .collection("Users")
        .add(user.toJson())
        .whenComplete(() => Get.snackbar(
              "Success",
              "Your account has been created",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.amber,
            ))
        .catchError((error, StackTrace) {
      Get.snackbar(
        "Error",
        "An error occurred: $error", // Display the error message
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            Colors.red, // You can customize the background color for errors
      );
    });
  }
}
