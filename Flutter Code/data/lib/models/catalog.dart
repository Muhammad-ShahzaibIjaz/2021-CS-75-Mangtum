class catalogModel {
  static final item = [
    Items(
        id: "01",
        name: "Tate Pickett",
        desc:
            "Saepe dolores illum quisquam sit totam sit sunt in sed laborum consectetur veniam natus velit expedita eveniet",
        price: 500,
        image:
            "https://www.dressyzone.com/cdn/shop/products/p14769-embroidered-bridal-maxi-dress_540x.jpg?v=1645684044")
  ];
}

class Items {
  final String id;
  final String name;
  final String desc;
  final num price;
  final String image;

  Items(
      {required this.id,
      required this.name,
      required this.desc,
      required this.price,
      required this.image});
}
