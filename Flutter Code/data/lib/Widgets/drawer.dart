import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(
                  "Mangtum",
                  textScaleFactor: 1.2,
                  style: TextStyle(color: Colors.amber),
                ),
                accountEmail: Text(
                  "mangtum@gmail.com",
                  textScaleFactor: 1.2,
                  style: TextStyle(color: Colors.amber),
                ),
                currentAccountPicture:
                    Image.asset("Assets/images/MangtumLogo.png"),
                decoration: BoxDecoration(color: Colors.white),
              )),
          ListTile(
            leading: Icon(
              CupertinoIcons.home,
              color: Colors.amber,
            ),
            title: Text(
              "Home",
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.amber),
            ),
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.profile_circled,
              color: Colors.amber,
            ),
            title: Text(
              "Profile",
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.amber),
            ),
          )
        ], //children
      ),
    );
  }
}
