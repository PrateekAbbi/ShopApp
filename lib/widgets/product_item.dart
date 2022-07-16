// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../screens/product_detail.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  // final String id;
  // final String title;
  // final String imageUrl;

  // const ProductItem(
  //     {Key? key, required this.id, required this.title, required this.imageUrl})
  //     : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, value, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(auth.token, auth.userId);
                } catch (err) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(err.toString()),
                      duration: const Duration(
                        seconds: 5,
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.all(20),
                    ),
                  );
                }
              },
              color: Colors.deepOrange,
              // color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Added item to cart"),
                  duration: const Duration(
                    seconds: 5,
                  ),
                  action: SnackBarAction(
                    textColor: Colors.white,
                    label: "UNDO",
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: const AssetImage(
                "assets/images/product-placeholder.png",
              ),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
