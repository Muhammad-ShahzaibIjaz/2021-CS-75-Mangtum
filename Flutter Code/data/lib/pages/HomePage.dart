import 'package:data/Widgets/drawer.dart';
import 'package:data/Widgets/item_widget.dart';
import 'package:data/models/catalog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummylist = List.generate(50, (index) => catalogModel.item[0]);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.login))
        ],
        title: Text(
          "Mangtum",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: dummylist.length,
          //itemCount: catalogModel.item.length,
          itemBuilder: (context, index) {
            return ItemWidget(
              item: dummylist[index],
              //item: catalogModel.item[index],
            );
          }),
      drawer: MyDrawer(),
    );
  }
}
