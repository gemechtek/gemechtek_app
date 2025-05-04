import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/firebase_services/local_pref.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/backend/model/user_model.dart';
import 'package:spark_aquanix/backend/providers/cart_provider.dart';
import 'package:spark_aquanix/backend/providers/order_provider.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/view/products/widgets/image_carousel.dart';

import 'widgets/custom_dropdown.dart';
import 'widgets/custom_text_filed.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  PaymentType _selectedPaymentMethod = PaymentType.cash;
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacingOrder = true;
    });
    UserModel? userModel = await LocalPreferenceService().getUserData();
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      final deliveryAddress = DeliveryAddress(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
      );

      const double tax = 0.1; // 10% tax rate
      const double shippingCost = 5.0; // Fixed shipping cost

      await orderProvider.placeOrder(
        userId: userModel?.id ?? "",
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

              // Delivery Address
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Full Name',
                keyboardType: TextInputType.name,
              ),
              CustomTextField(
                controller: _phoneNumberController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(
                controller: _addressLine1Controller,
                labelText: 'Address Line 1',
                keyboardType: TextInputType.streetAddress,
              ),
              CustomTextField(
                controller: _addressLine2Controller,
                labelText: 'Address Line 2 (Optional)',
                isRequired: false,
                keyboardType: TextInputType.streetAddress,
              ),
              CustomTextField(
                controller: _cityController,
                labelText: 'City',
                keyboardType: TextInputType.text,
              ),
              CustomTextField(
                controller: _stateController,
                labelText: 'State',
                keyboardType: TextInputType.text,
              ),
              CustomTextField(
                controller: _postalCodeController,
                labelText: 'Postal Code',
                keyboardType: TextInputType.number,
              ),
              CustomTextField(
                controller: _countryController,
                labelText: 'Country',
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 12),

              // Payment Method
              // const Text(
              //   'Payment Method',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 12),
              // DropdownButtonFormField<PaymentType>(
              //   value: _selectedPaymentMethod,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //   ),
              //   items: PaymentType.values
              //       .map((method) => DropdownMenuItem(
              //             value: method,
              //             child: Text(method.toString().split('.').last),
              //           ))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedPaymentMethod = value!;
              //     });
              //   },
              // ),
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
                  onPressed:
                      _isPlacingOrder ? null : () => _placeOrder(context),
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
