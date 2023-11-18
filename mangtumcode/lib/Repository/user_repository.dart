import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mangtumcode/models/users_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  createUser(Users user) async {
    _db
        .collection("Users")
        .add(user.toJson())
        .whenComplete(() => Get.snackbar(
              "Success",
              "Your account has been created",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.amber,
            ))
        // ignore: body_might_complete_normally_catch_error
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
