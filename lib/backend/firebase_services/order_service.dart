import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/constants/enums/order_status.dart';

class OrderService {
  final CollectionReference _ordersCollection;
  final CollectionReference _productsCollection;

  OrderService()
      : _ordersCollection = FirebaseFirestore.instance.collection('orders'),
        _productsCollection = FirebaseFirestore.instance.collection('products');

  // Place a new order
  Future<String> placeOrder(OrderDetails order) async {
    try {
      // Create the order in Firestore
      DocumentReference orderRef = await _ordersCollection.add(order.toMap());

      // Update product stock and itemSold in a transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Step 1: Collect all read operations
        final productSnapshots = <String, DocumentSnapshot>{};
        for (var item in order.items) {
          DocumentReference productRef =
              _productsCollection.doc(item.productId);
          DocumentSnapshot productSnapshot = await transaction.get(productRef);
          productSnapshots[item.productId] = productSnapshot;
        }

        // Step 2: Perform all write operations
        for (var item in order.items) {
          DocumentReference productRef =
              _productsCollection.doc(item.productId);
          DocumentSnapshot productSnapshot = productSnapshots[item.productId]!;

          if (productSnapshot.exists) {
            Map<String, dynamic> productData =
                productSnapshot.data() as Map<String, dynamic>;

            int currentStock = productData['stock'] ?? 0;
            int currentItemSold = productData['itemSold'] ?? 0;

            // Prepare update data
            final updateData = {
              'stock': currentStock - item.quantity,
              'itemSold': currentItemSold + item.quantity,
              'updatedAt': Timestamp.now(),
            };

            // If stock becomes 0, set status to Out Of Stock
            if (currentStock - item.quantity <= 0) {
              updateData['status'] = 'Out Of Stock';
            }

            // Update product
            transaction.update(productRef, updateData);
          }
        }
      });

      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  // Get user's orders
  Stream<List<OrderDetails>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderDetails.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get a specific order
  Future<OrderDetails?> getOrderById(String orderId) async {
    DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
    if (doc.exists) {
      return OrderDetails.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      // Get the order to retrieve the items
      DocumentSnapshot orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');

      Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
      OrderDetails order = OrderDetails.fromFirestore(orderData, orderId);

      // Only allow cancellation if the order is pending or processing
      if (order.status != OrderStatus.pending &&
          order.status != OrderStatus.processing) {
        throw Exception('Cannot cancel order in ${order.status} status');
      }

      // Update the order status to cancelled
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.toString(),
        'updatedAt': Timestamp.now(),
      });

      // Restore product stock in a transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (var item in order.items) {
          DocumentReference productRef =
              _productsCollection.doc(item.productId);
          DocumentSnapshot productSnapshot = await transaction.get(productRef);

          if (productSnapshot.exists) {
            Map<String, dynamic> productData =
                productSnapshot.data() as Map<String, dynamic>;

            int currentStock = productData['stock'] ?? 0;
            int currentItemSold = productData['itemSold'] ?? 0;

            // Update stock and itemSold
            transaction.update(productRef, {
              'stock': currentStock + item.quantity,
              'itemSold': currentItemSold - item.quantity,
              'updatedAt': Timestamp.now(),
            });

            // If status was Out Of Stock and now has stock, set back to Active
            if (productData['status'] == 'Out Of Stock' &&
                currentStock + item.quantity > 0) {
              transaction.update(productRef, {
                'status': 'Active',
              });
            }
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
