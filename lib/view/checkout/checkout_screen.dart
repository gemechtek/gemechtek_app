import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/firebase_services/local_pref.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/backend/model/user_model.dart';
import 'package:spark_aquanix/backend/providers/cart_provider.dart';
import 'package:spark_aquanix/backend/providers/order_provider.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/view/products/widgets/image_carousel.dart';
import 'package:uuid/uuid.dart';

import 'widgets/address_card.dart';
import 'widgets/address_form.dart';
import 'widgets/custom_dropdown.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  PaymentType _selectedPaymentMethod = PaymentType.cash;
  bool _isPlacingOrder = false;
  bool _showAddressForm = false;
  DeliveryAddress? _selectedAddress;
  DeliveryAddress? _addressBeingEdited;
  List<DeliveryAddress> _savedAddresses = [];
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final addresses = await LocalPreferenceService().getSavedAddresses();
      final defaultAddress = addresses.isNotEmpty
          ? addresses.firstWhere((addr) => addr.isDefault,
              orElse: () => addresses.first)
          : null;

      setState(() {
        _savedAddresses = addresses;
        _selectedAddress = defaultAddress;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load addresses: $e')),
      );
    }
  }

  Future<void> _saveAddress(DeliveryAddress address) async {
    try {
      await LocalPreferenceService().saveAddress(address);

      // Reset form state
      setState(() {
        _showAddressForm = false;
        _addressBeingEdited = null;
      });

      // Reload addresses
      await _loadSavedAddresses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save address: $e')),
      );
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await LocalPreferenceService().deleteAddress(addressId);
      await _loadSavedAddresses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address: $e')),
      );
    }
  }

  void _editAddress(DeliveryAddress address) {
    setState(() {
      _addressBeingEdited = address;
      _showAddressForm = true;
    });
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select or add a delivery address')),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    UserModel? userModel = await LocalPreferenceService().getUserData();
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final deliveryAddress = DeliveryAddress(
        id: _selectedAddress!.id,
        fullName: _selectedAddress!.fullName,
        phoneNumber: _selectedAddress!.phoneNumber,
        addressLine1: _selectedAddress!.addressLine1,
        addressLine2: _selectedAddress!.addressLine2,
        city: _selectedAddress!.city,
        state: _selectedAddress!.state,
        postalCode: _selectedAddress!.postalCode,
        country: _selectedAddress!.country,
      );

      const double tax = 0.1;
      const double shippingCost = 5.0;

      await orderProvider.placeOrder(
        userId: userModel?.id ?? "",
        name: userModel?.name ?? "",
        fcm: userModel?.fcmToken ?? "",
        cartItems: cartProvider.items,
        deliveryAddress: deliveryAddress,
        paymentMethod: _selectedPaymentMethod,
        subtotal: cartProvider.totalAmount,
        tax: cartProvider.totalAmount * tax,
        shippingCost: shippingCost,
      );

      // Clear cart after successful order
      cartProvider.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  List<PaymentType> _getCommonPaymentTypes(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.items.isEmpty) return [];

    // Get the paymentTypes lists from all CartItems
    final paymentTypesLists =
        cartProvider.items.map((item) => item.paymentTypes).toList();

    // Check if any item has PaymentType.all
    bool hasAllPaymentTypes = paymentTypesLists
        .any((paymentTypes) => paymentTypes.contains(PaymentType.all));

    List<PaymentType> result;
    if (hasAllPaymentTypes) {
      // If any item supports all payment types, show all options except PaymentType.all
      result =
          PaymentType.values.where((type) => type != PaymentType.all).toList();
    } else {
      // Otherwise, find the intersection of all paymentTypes lists, excluding PaymentType.all
      Set<PaymentType> commonPaymentTypes = paymentTypesLists.first
          .where((type) => type != PaymentType.all)
          .toSet();
      for (var paymentTypes in paymentTypesLists.skip(1)) {
        commonPaymentTypes = commonPaymentTypes.intersection(
            paymentTypes.where((type) => type != PaymentType.all).toSet());
      }
      result = commonPaymentTypes.toList();
    }

    // Ensure the current _selectedPaymentMethod is valid; if not, set to first available
    if (!result.contains(_selectedPaymentMethod) && result.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedPaymentMethod = result.first;
        });
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    const double tax = 0.1; // 10% tax rate
    const double shippingCost = 5.0; // Fixed shipping cost
    final subtotal = cartProvider.totalAmount;
    final total = subtotal + (subtotal * tax) + shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items
              const Text(
                'Order Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...cartProvider.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      children: [
                        ImageCarousel(images: [item.image]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          'Qty: ${item.quantity} | Size: ${item.size} | Color: ${item.selectedColor}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 24),

              // Delivery Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!_showAddressForm && _savedAddresses.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18, color: Colors.blue),
                      label: const Text('Add New'),
                      onPressed: () {
                        setState(() {
                          _showAddressForm = true;
                          _addressBeingEdited = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingAddresses)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_showAddressForm)
                // Show address form for adding/editing
                AddressForm(
                  initialAddress: _addressBeingEdited,
                  onSave: _saveAddress,
                  onCancel: () {
                    setState(() {
                      _showAddressForm = false;
                      _addressBeingEdited = null;
                    });
                  },
                )
              else if (_savedAddresses.isEmpty)
                // No saved addresses
                Column(
                  children: [
                    const Text(
                      'No saved addresses. Please add a delivery address.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text('Add New Address'),
                      onPressed: () {
                        setState(() {
                          _showAddressForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              else
                // List of saved addresses
                Column(
                  children: _savedAddresses.map((address) {
                    final isSelected = _selectedAddress?.id == address.id;
                    return AddressCard(
                      address: address,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedAddress = address;
                        });
                      },
                      onEdit: () => _editAddress(address),
                      onDelete: () => _deleteAddress(address.id),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // Payment Method
              CustomDropdownButtonFormField<PaymentType>(
                value: _selectedPaymentMethod,
                labelText: 'Payment Method',
                items: _getCommonPaymentTypes(context)
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Order Summary
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax (10%)'),
                  Text('\$${(subtotal * tax).toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shipping'),
                  Text('\$${shippingCost.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAddress == null || _isPlacingOrder
                      ? null
                      : () => _placeOrder(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
