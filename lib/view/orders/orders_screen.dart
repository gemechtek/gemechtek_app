import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/firebase_services/local_pref.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/backend/model/user_model.dart';
import 'package:spark_aquanix/backend/providers/order_provider.dart';
import 'package:spark_aquanix/constants/enums/order_status.dart';
import 'package:intl/intl.dart';

import 'order_details_screen.dart';
import 'widgets/order_tracking_bottomsheet.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _init();
  }

  void _init() async {
    _userModel = await LocalPreferenceService().getUserData();
    if (_userModel != null) {
      Provider.of<OrderProvider>(context, listen: false)
          .fetchUserOrders(_userModel!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            );
          }

          final ongoingOrders = orderProvider.orders
              .where((order) =>
                  order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled)
              .toList();
          final completedOrders = orderProvider.orders
              .where((order) =>
                  order.status == OrderStatus.delivered ||
                  order.status == OrderStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(context, ongoingOrders, orderProvider, true),
              _buildOrderList(context, completedOrders, orderProvider, false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderDetails> orders,
      OrderProvider orderProvider, bool isOngoing) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isOngoing
                  ? 'No ongoing orders'
                  : 'No completed or cancelled orders',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Since we might have multiple items per order, just show the first one in the list view
        final firstItem = order.items.first;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: firstItem.image.isNotEmpty
                              ? Image.network(
                                  firstItem.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Order details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  firstItem.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Display status with color
                            Text(
                              order.status.toString(),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Delivered date or expected delivery
                            Text(
                              order.status == OrderStatus.delivered
                                  ? 'Delivered on ${DateFormat('dd MMM yyyy').format(order.updatedAt ?? order.createdAt)}'
                                  : 'Delivery Expected by ${DateFormat('dd MMM yyyy').format(order.createdAt.add(const Duration(days: 7)))}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Order ID
                            Text(
                              'Order ID: ${order.id?.substring(0, 10)}...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Rating or Track button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // order.status == OrderStatus.delivered
                      //     ? const Row(
                      //         children: [
                      //           Text('Rate this Product'),
                      //           SizedBox(width: 8),
                      //           Icon(Icons.star_border, size: 18),
                      //           Icon(Icons.star_border, size: 18),
                      //           Icon(Icons.star_border, size: 18),
                      //           Icon(Icons.star_border, size: 18),
                      //           Icon(Icons.star_border, size: 18),
                      //         ],
                      //       )
                      //     : const SizedBox(),
                      ElevatedButton(
                        onPressed: () {
                          _showTrackingBottomSheet(context, order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Track'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showTrackingBottomSheet(BuildContext context, OrderDetails order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderTrackingBottomSheet(order: order),
    );
  }
}
