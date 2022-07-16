import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String? authToken;
  final String? userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken",
    );
    final timeStamp = DateTime.now();
    final data = await http.post(
      url,
      body: json.encode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts
            .map((ele) => {
                  "id": ele.id,
                  "title": ele.title,
                  "quantity": ele.quantity,
                  "price": ele.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(data.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken",
    );
    final data = await http.get(url);
    final List<OrderItem> loadedOrders = [];

    final extractedData = json.decode(data.body); //as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData["amount"],
        products: (orderData["products"] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item["id"],
                title: item["title"],
                quantity: item["quantity"],
                price: item["price"],
              ),
            )
            .toList(),
        dateTime: DateTime.parse(orderData["dateTime"]),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
