import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyThemes {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: GoogleFonts.lato().fontFamily,
      appBarTheme: AppBarTheme(
        color: Colors.amber,
        iconTheme: IconThemeData(color: Colors.white),
        //textTheme: Theme.of(context).textTheme,
        elevation: 0.0,
      ));
}
