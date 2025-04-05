import 'package:flutter/material.dart';
import 'package:gemechtek_app/navigation/navigator_helper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Cart Item ${index + 1}'),
                  trailing: Text('\$${(index + 1) * 10}.99'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => NavigationHelper.navigateToCheckout(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
