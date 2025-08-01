import 'package:flutter/material.dart';
import 'package:spark_aquanix/view/auth/login.dart';
import 'package:spark_aquanix/view/auth/screen/auth.dart';
import 'package:spark_aquanix/view/checkout/checkout_screen.dart';
import 'package:spark_aquanix/view/checkout/widgets/order_placed.dart';
import 'package:spark_aquanix/view/home/home_screen.dart';
import 'package:spark_aquanix/view/notification/notification_screen.dart';
import 'package:spark_aquanix/view/products/product_details.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:spark_aquanix/view/profile/screens/edit_profile.dart';
import 'package:spark_aquanix/view/profile/screens/settings_screen.dart';

import 'main_navigation.dart';

class NavigationHelper {
  // Helper method to switch to a specific tab
  static void _switchToTab(int tabIndex) {
    final controller = MainNavigationScreen.controller;
    if (controller != null) {
      controller.jumpToTab(tabIndex);
    }
  }

  static void navigateToHome(BuildContext context) {
    _switchToTab(0);
    // pushScreen(
    //   context,
    //   screen: const HomeScreen(),
    //   withNavBar: true,
    //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
    // );
  }

  static void navigateToOrders(BuildContext context) {
    _switchToTab(1);
    // pushScreen(
    //   context,
    //   screen: const HomeScreen(),
    //   withNavBar: true,
    //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
    // );
  }

  static void navigateToProductDetails(BuildContext context, String productId) {
    pushScreen(
      context,
      screen: ProductDetailScreen(productId: productId),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToNotificationScreen(BuildContext context) {
    pushScreen(
      context,
      screen: NotificationsScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToSettingsScreen(BuildContext context) {
    pushScreen(
      context,
      screen: SettingsScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToCheckout(BuildContext context) {
    pushScreen(
      context,
      screen: const CheckoutScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToCart(BuildContext context) {
    _switchToTab(2);
    // pushScreen(
    //   context,
    //   screen: const CartScreen(),
    //   withNavBar: true,
    //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
    // );
  }

  static void navigateToEditProfile(BuildContext context) {
    pushScreen(
      context,
      screen: const EditProfileScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToOrderPlaced(BuildContext context) {
    pushScreen(
      context,
      screen: const OrderPlaced(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  static void navigateToLogin(BuildContext context) {
    pushReplacementWithoutNavBar(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  static void navigateToHomeMain(BuildContext context) {
    pushReplacementWithNavBar(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }
}
