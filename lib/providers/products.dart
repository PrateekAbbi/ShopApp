// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../model/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavsOnly = false;

  List<Product> get items {
    // if (_showFavsOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favsItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavsOnly() {
  //   _showFavsOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavsOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/products.json",
    );
    try {
      final data = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "isFavorite": product.isFavorite,
        }),
      );
      final newProduct = Product(
        id: json.decode(data.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/products.json",
    );
    try {
      final response = await http.get(url);

      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      data.forEach((id, ele) {
        loadedProducts.add(
          Product(
            id: id,
            title: ele["title"],
            description: ele["description"],
            price: ele["price"],
            imageUrl: ele["imageUrl"],
            isFavorite: ele["isFavorite"],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/products/$id.json",
    );
    var productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      await http.patch(
        url,
        body: json.encode({
          "title": updatedProduct.title,
          "description": updatedProduct.description,
          "imageUrl": updatedProduct.imageUrl,
          "price": updatedProduct.price,
        }),
      );
      _items[productIndex] = updatedProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      "https://shopapp-2cb25-default-rtdb.firebaseio.com/products/$id.json",
    );
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final data = await http.delete(url);
    if (data.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException(
        "Something went wrong. We were not able to delete your product. We request you to try again after some time.",
      );
    }

    existingProduct = null;
  }
}
