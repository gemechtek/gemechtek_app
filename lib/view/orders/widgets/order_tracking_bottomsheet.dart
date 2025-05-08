import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/backend/providers/order_provider.dart';
import 'package:spark_aquanix/constants/enums/order_status.dart';

class OrderTrackingBottomSheet extends StatelessWidget {
  final OrderDetails order;

  const OrderTrackingBottomSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Tracking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Order ID: ${order.id?.substring(0, 10)}...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Display expected delivery date if available
                    if (order.estimatedDeliveryDate != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expected Delivery',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('EEEE, dd MMM yyyy')
                                        .format(order.estimatedDeliveryDate!),
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    _buildTrackingTimeline(context, order),

                    const SizedBox(height: 20),

                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.deliveryAddress.fullName}\n'
                      '${order.deliveryAddress.addressLine1}, '
                      '${order.deliveryAddress.addressLine2.isNotEmpty ? '${order.deliveryAddress.addressLine2}, ' : ''}'
                      '${order.deliveryAddress.city}, ${order.deliveryAddress.state}, '
                      '${order.deliveryAddress.postalCode}, ${order.deliveryAddress.country}\n'
                      'Phone: ${order.deliveryAddress.phoneNumber}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 20),

                    // Status History
                    const Text(
                      'Status History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusHistory(order),

                    const SizedBox(height: 20),

                    // Cancel Order button if applicable
                    if (order.status == OrderStatus.pending ||
                        order.status == OrderStatus.orderConfirmed)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await Provider.of<OrderProvider>(context,
                                      listen: false)
                                  .cancelOrder(order.id!);
                              Navigator.pop(context);
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Cancel Order'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusHistory(OrderDetails order) {
    // Reverse the list to show most recent status first
    final sortedHistory = List<StatusChange>.from(order.statusHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      children: sortedHistory.map((statusChange) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(statusChange.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(statusChange.status),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(statusChange.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (statusChange.comment != null &&
                        statusChange.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          statusChange.comment!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrackingTimeline(BuildContext context, OrderDetails order) {
    // All possible statuses in order
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.orderConfirmed,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    // Get the current status index
    final currentStatusIndex = allStatuses.indexWhere((s) => s == order.status);

    // If cancelled, show a special timeline
    if (order.status == OrderStatus.cancelled) {
      return Column(
        children: [
          _buildTimelineItem(
            context: context,
            title: 'Order Placed',
            date: DateFormat('dd MMM yyyy').format(order.createdAt),
            isCompleted: true,
            isFirst: true,
            isLast: false,
          ),
          _buildTimelineItem(
            context: context,
            title: 'Order Cancelled',
            date: DateFormat('dd MMM yyyy').format(order.updatedAt),
            isCompleted: true,
            isFirst: false,
            isLast: true,
            isError: true,
          ),
        ],
      );
    }

    return Column(
      children: List.generate(
        allStatuses.length,
        (index) {
          final status = allStatuses[index];
          final isCompleted = index <= currentStatusIndex;

          String date = '';
          if (isCompleted) {
            // For completed statuses, find the actual date from status history
            final statusChange = order.statusHistory.lastWhere(
              (change) => change.status == status,
              orElse: () => StatusChange(
                status: status,
                timestamp: order.createdAt,
              ),
            );
            date = DateFormat('dd MMM yyyy').format(statusChange.timestamp);
          } else {
            // For future statuses, show expected date
            if (status == OrderStatus.delivered &&
                order.estimatedDeliveryDate != null) {
              date =
                  'Expected ${DateFormat('dd MMM yyyy').format(order.estimatedDeliveryDate!)}';
            } else {
              // For other future statuses, estimate dates
              final baseDate = order.statusHistory.isNotEmpty &&
                      order.statusHistory.last.status ==
                          OrderStatus.orderConfirmed
                  ? order.statusHistory.last.timestamp
                  : order.createdAt;

              int daysToAdd;
              switch (status) {
                case OrderStatus.orderConfirmed:
                  daysToAdd = 1;
                  break;
                case OrderStatus.shipped:
                  daysToAdd = 1;
                  break;
                case OrderStatus.outForDelivery:
                  daysToAdd = 2;
                  break;
                case OrderStatus.delivered:
                  daysToAdd = Random().nextBool() ? 2 : 3;
                  break;
                default:
                  daysToAdd = index;
              }

              date = 'Expected ${DateFormat('dd MMM yyyy').format(
                baseDate.add(Duration(days: daysToAdd)),
              )}';
            }
          }

          return _buildTimelineItem(
            context: context,
            title: _getStatusTitle(status),
            date: date,
            isCompleted: isCompleted,
            isFirst: index == 0,
            isLast: index == allStatuses.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String title,
    required String date,
    required bool isCompleted,
    required bool isFirst,
    required bool isLast,
    bool isError = false,
  }) {
    final Color activeColor = isError ? Colors.red : Colors.blue;
    final Color inactiveColor = Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? activeColor : inactiveColor,
              ),
              child: isCompleted
                  ? Icon(
                      isError ? Icons.close : Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: isCompleted ? activeColor : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.orderConfirmed:
        return 'Order Confirmed';
      case OrderStatus.shipped:
        return 'Order Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.orderConfirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
