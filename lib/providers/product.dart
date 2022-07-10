import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/products/$id.json",
    );

    bool? oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final data = await http.patch(
      url,
      body: json.encode(
        {
          "isFavorite": isFavorite,
        },
      ),
    );

    if (data.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
      throw HttpException(
        "Unable to update the product, please try again after some time!",
      );
    }
    oldStatus = null;
  }
}
