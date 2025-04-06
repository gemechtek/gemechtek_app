// File: lib/navigation/navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:spark_aquanix/view/cart/cart_screen.dart';
import 'package:spark_aquanix/view/checkout/checkout_screen.dart';
import 'package:spark_aquanix/view/products/product_details.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class NavigationHelper {
  static void navigateToProductDetails(BuildContext context, String productId) {
    pushScreen(
      context,
      screen: ProductDetailsScreen(productId: productId),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToCheckout(BuildContext context) {
    pushScreen(
      context,
      screen: CheckoutScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToCart(BuildContext context) {
    pushScreen(
      context,
      screen: CartScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  // static void navigateToOrderSummary(BuildContext context, String orderId) {
  //   pushScreen(
  //     context,
  //     screen: OrderSummaryScreen(orderId: orderId),
  //     withNavBar: false, // Hide nav bar
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }

  // static void navigateToSettings(BuildContext context) {
  //   pushScreen(
  //     context,
  //     screen: SettingsScreen(),
  //     withNavBar: false, // Hide nav bar
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }

  // static void navigateToLogin(BuildContext context) {
  //   pushScreen(
  //     context,
  //     screen: LoginScreen(),
  //     withNavBar: false, // Hide nav bar
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }

  // static void navigateToOnboarding(BuildContext context) {
  //   pushScreen(
  //     context,
  //     screen: OnboardingScreen(),
  //     withNavBar: false, // Hide nav bar
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }

  // static void navigateToOnboarding(BuildContext context) {
  //   pushScreen(
  //     context,
  //     screen: OnboardingScreen(),
  //     withNavBar: false, // Hide nav bar
  //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
  //   );
  // }
}
