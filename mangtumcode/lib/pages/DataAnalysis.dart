import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSalesChartPage extends StatefulWidget {
  @override
  _ProductSalesChartPageState createState() => _ProductSalesChartPageState();
}

class _ProductSalesChartPageState extends State<ProductSalesChartPage> {
  List<Order>? orderHistory;
  Map<String, String>? productNames;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Fetch order history
    List<OrderHistory> orderHistoryData = await fetchOrderHistory();

    // Fetch product names
    Map<String, String> productNamesData = await fetchProductNames();

    // Convert order history to Order
    orderHistory = convertToOrderList(orderHistoryData);

    // Set product names
    productNames = productNamesData;

    // Rebuild the widget after fetching data
    setState(() {});
  }

  Future<List<OrderHistory>> fetchOrderHistory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> orderHistorySnapshot =
          await FirebaseFirestore.instance.collection('OrderHistory').get();

      return orderHistorySnapshot.docs
          .map((doc) => OrderHistory.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error fetching order history: $e');
      return [];
    }
  }

  Future<Map<String, String>> fetchProductNames() async {
    try {
      QuerySnapshot<Map<String, dynamic>> productsSnapshot =
          await FirebaseFirestore.instance.collection('Products').get();

      return Map.fromIterable(
        productsSnapshot.docs,
        key: (doc) => doc.id,
        value: (doc) => doc.data()?['productName'],
      );
    } catch (e) {
      print('Error fetching product names: $e');
      return {};
    }
  }

  List<Order> convertToOrderList(List<OrderHistory> orderHistory) {
    return orderHistory.map((orderHistory) {
      return Order(cartItems: orderHistory.cartItems);
    }).toList();
  }

  Map<String, int> countProductSales(List<Order> orderHistory) {
    Map<String, int> productSales = {};

    for (Order order in orderHistory) {
      for (CartItem cartItem in order.cartItems) {
        String productId = cartItem.productId;

        if (productSales.containsKey(productId)) {
          productSales[productId] = productSales[productId]! + 1;
        } else {
          productSales[productId] = 1;
        }
      }
    }

    return productSales;
  }

  List<PieChartSectionData> generateChartData(Map<String, int> productSales) {
    List<PieChartSectionData> sections = [];

    productSales.forEach((productId, count) {
      String productName = productNames?[productId] ?? 'Unknown Product';

      sections.add(
        PieChartSectionData(
          color: getRandomColor(productSales),
          value: count.toDouble(),
          title: count > 1
              ? '$productName\n$count units'
              : '$productName\n$count unit',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  Color getRandomColor(Map<String, int> productSales) {
    return Colors.primaries[productSales.length % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Sales Chart'),
      ),
      body: Center(
        child: orderHistory != null && productNames != null
            ? productNames!.isNotEmpty
                ? Column(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: generateChartData(
                                countProductSales(orderHistory!)),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Product Sales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text('No product names available.')
            : CircularProgressIndicator(),
      ),
    );
  }
}

class Order {
  List<CartItem> cartItems;

  Order({required this.cartItems});
}

class CartItem {
  String productId;

  CartItem({required this.productId});
}

class OrderHistory {
  List<CartItem> cartItems;

  OrderHistory({required this.cartItems});

  factory OrderHistory.fromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    List<CartItem> cartItems =
        List<Map<String, dynamic>>.from(doc.data()['cartItems'] ?? [])
            .map((item) => CartItem(productId: item['productId']))
            .toList();

    return OrderHistory(cartItems: cartItems);
  }
}
