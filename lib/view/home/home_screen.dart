import 'package:flutter/material.dart';
import 'package:spark_aquanix/navigation/navigator_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.settings),
          //   onPressed: () => NavigationHelper.navigateToSettings(context),
          // ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final productId = 'product_${index + 1}';
          return ListTile(
            title: Text('Product ${index + 1}'),
            onTap: () =>
                NavigationHelper.navigateToProductDetails(context, productId),
          );
        },
      ),
    );
  }
}
