// ignore_for_file: prefer_const_constructors

import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import "./screens/products_overview.dart";
import './screens/product_detail.dart';
import './screens/user_products.dart';
import './screens/cart.dart';
import './screens/orders.dart';
import './screens/edit_product.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products(null, [], null),
          update: (context, auth, products) => Products(
            auth.token,
            products!.items,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders(null, [], null),
          update: (context, auth, orders) => Orders(
            auth.token,
            orders!.orders,
            auth.userId,
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          title: "MyShop",
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: authData.isAuth
              ? ProductsOverViewScreen()
              : FutureBuilder(
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                  future: authData.tryAutoLogin(),
                ),
          routes: {
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
