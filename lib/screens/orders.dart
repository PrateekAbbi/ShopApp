import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  const OrdersScreen({Key? key}) : super(key: key);

  /* 
  If you have something which cause to rebuild the widget, then it is advised to 
  convert your Widget into Stateful and widget and follow these steps:

  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  And then where you are using FutureBuilder, there in future:_ordersFuture;

  This approach will prevent creating new Future every time Widget is rebuild.
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return const Center(
                child: Text("An error occured!"),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, i) =>
                      OrderItem(order: orderData.orders[i]),
                ),
              );
            }
          }
        },
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
      ),
    );
  }
}
