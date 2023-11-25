import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mangtumcode/pages/HomePage.dart';

import 'package:mangtumcode/pages/UpdateProfilePageBuyer.dart';
import 'package:mangtumcode/pages/WishlistPage.dart';

class BuyerEntryPage extends StatefulWidget {
  final String userId;
  BuyerEntryPage({required this.userId});

  @override
  _BuyerEntryPageState createState() => _BuyerEntryPageState();
}

class _BuyerEntryPageState extends State<BuyerEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header widget
            Header(),

            // SearchBar widget
            SearchBar(),

            // Text with spacing
            Text('All Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),

            // CategoriesRow widget
            CategoriesRow(),

            // Spacing between categories and image
            SizedBox(height: 20),

            // ClipRRect with CachedNetworkImage and SizedBox for width and height
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                width: 400,
                height: 250,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.pexels.com/photos/6830808/pexels-photo-6830808.jpeg?auto=compress&cs=tinysrgb&w=1600',
                  fit: BoxFit.fill,
                ),
              ),
            ),

            // Text with spacing
            Text('Variety All For You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // ClipRRect with Image.asset and SizedBox for width and height
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                width: 400,
                height: 270,
                child: Image.asset("assets/images/Deals for you .jpg"),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    print('Home icon clicked!');
                    // Navigate to home page
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UpdateProfilePageBuyer(userId: widget.userId)),
                    );
                    print('Profile icon clicked!');
                    // Navigate to profile page
                  },
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WishlistPage(widget.userId)),
                    );
                    print('Favorite icon clicked!');
                    // Navigate to favorites page
                  },
                ),
                IconButton(
                  icon: Icon(Icons.production_quantity_limits),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage(userId: widget.userId)),
                    );
                    print('Cart icon clicked!');
                    // Navigate to cart page
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/images/MangtumLogo.png'),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final String categoryName;

  const CategoryItem({required this.imageUrl, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: 63,
            height: 90,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(categoryName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CategoriesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CategoryItem(
            imageUrl:
                'https://images.pexels.com/photos/5210710/pexels-photo-5210710.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
            categoryName: 'Dress'),
        SizedBox(width: 10),
        CategoryItem(
            imageUrl:
                'https://images.pexels.com/photos/14118001/pexels-photo-14118001.jpeg?auto=compress&cs=tinysrgb&w=1600',
            categoryName: 'Jewellery'),
        SizedBox(width: 10),
        CategoryItem(
            imageUrl:
                'https://images.pexels.com/photos/13611901/pexels-photo-13611901.jpeg?auto=compress&cs=tinysrgb&w=1600',
            categoryName: 'Shoes'),
        SizedBox(width: 10),
        CategoryItem(
            imageUrl:
                'https://images.pexels.com/photos/11124989/pexels-photo-11124989.jpeg?auto=compress&cs=tinysrgb&w=1600',
            categoryName: 'Bags'),
        SizedBox(width: 10),
        CategoryItem(
            imageUrl:
                'https://images.pexels.com/photos/1759618/pexels-photo-1759618.jpeg?auto=compress&cs=tinysrgb&w=1600',
            categoryName: 'Eyewear'),
      ],
    );
  }
}
