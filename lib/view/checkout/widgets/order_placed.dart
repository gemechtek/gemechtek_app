import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spark_aquanix/navigation/navigator_helper.dart';

class OrderPlaced extends StatelessWidget {
  const OrderPlaced({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0089FF),
      appBar: AppBar(
        backgroundColor: Color(0xff0089FF),
        leading: IconButton(
            onPressed: () {
              NavigationHelper.navigateToHomeMain(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            children: [
              SizedBox(
                  height: 260,
                  child: Lottie.asset(
                      repeat: false, "assets/lottie/orderconfirmed.json")),
              Text(
                "Order Confirmed",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                "Thank you for trusting us..",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    NavigationHelper.navigateToHomeMain(context);
                  },
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ),
                      child: Text(
                        "Continue Shopping",
                        style: TextStyle(fontSize: 16),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
