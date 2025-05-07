import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/firebase_services/local_pref.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/backend/model/user_model.dart';
import 'package:spark_aquanix/backend/providers/order_provider.dart';
import 'package:spark_aquanix/constants/enums/order_status.dart';
import 'package:spark_aquanix/view/products/widgets/image_carousel.dart';
import 'package:intl/intl.dart';

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
                  order.status != OrderStatus.delivered ||
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

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id?.substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(order.createdAt),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Order Status
                      Chip(
                        label: Text(
                          order.status.toString().split('.').last,
                          style: TextStyle(
                            color: order.status == OrderStatus.cancelled
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        backgroundColor: order.status == OrderStatus.cancelled
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                      ),
                      const SizedBox(height: 12),

                      // Order Items
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ImageCarousel(images: [item.image]),
                                const SizedBox(height: 8),
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Qty: ${item.quantity} | Size: ${item.size} | Color: ${item.selectedColor}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),

                      const Divider(),

                      // Order Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${order.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax'),
                          Text('\$${order.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shipping'),
                          Text('\$${order.shippingCost.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Delivery Address
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.deliveryAddress.fullName}\n'
                        '${order.deliveryAddress.addressLine1}, '
                        '${order.deliveryAddress.addressLine2.isNotEmpty ? '${order.deliveryAddress.addressLine2}, ' : ''}'
                        '${order.deliveryAddress.city}, ${order.deliveryAddress.state}, '
                        '${order.deliveryAddress.postalCode}, ${order.deliveryAddress.country}\n'
                        'Phone: ${order.deliveryAddress.phoneNumber}',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 12),

                      // Cancel Button for eligible orders
                      if (order.status == OrderStatus.pending ||
                          order.status == OrderStatus.processing)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                await orderProvider.cancelOrder(order.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Order cancelled successfully')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to cancel order: $e')),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel Order',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}
