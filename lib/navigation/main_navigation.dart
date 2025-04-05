import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemechtek_app/view/cart/cart_screen.dart';
import 'package:gemechtek_app/view/home/home_screen.dart';
import 'package:gemechtek_app/view/orders/orders_screen.dart';
import 'package:gemechtek_app/view/profile/profile_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  Widget _activeIcon(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        Colors.blue,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _inactiveIcon(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: _activeIcon('assets/navbar_icons/home.svg'),
            inactiveIcon: _inactiveIcon('assets/navbar_icons/home.svg'),
            title: "Home",
            activeForegroundColor: Colors.blue,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: const OrdersScreen(),
          item: ItemConfig(
            icon: _activeIcon('assets/navbar_icons/orders.svg'),
            inactiveIcon: _inactiveIcon('assets/navbar_icons/orders.svg'),
            title: "Orders",
            activeForegroundColor: Colors.blue,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: const CartScreen(),
          item: ItemConfig(
            icon: _activeIcon('assets/navbar_icons/cart.svg'),
            inactiveIcon: _inactiveIcon('assets/navbar_icons/cart.svg'),
            title: "Cart",
            activeForegroundColor: Colors.blue,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: ItemConfig(
            icon: _activeIcon('assets/navbar_icons/profile.svg'),
            inactiveIcon: _inactiveIcon('assets/navbar_icons/profile.svg'),
            title: "Profile",
            activeForegroundColor: Colors.blue,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) =>
          Style6BottomNavBar(navBarConfig: navBarConfig),
    );
  }
}
