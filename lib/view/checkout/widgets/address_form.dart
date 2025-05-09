import 'package:flutter/material.dart';

import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/view/checkout/widgets/custom_text_filed.dart';
import 'package:uuid/uuid.dart';

class AddressForm extends StatefulWidget {
  final DeliveryAddress? initialAddress;
  final Function(DeliveryAddress) onSave;
  final VoidCallback onCancel;

  const AddressForm({
    super.key,
    this.initialAddress,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if editing
    _fullNameController =
        TextEditingController(text: widget.initialAddress?.fullName ?? '');
    _phoneNumberController =
        TextEditingController(text: widget.initialAddress?.phoneNumber ?? '');
    _addressLine1Controller =
        TextEditingController(text: widget.initialAddress?.addressLine1 ?? '');
    _addressLine2Controller =
        TextEditingController(text: widget.initialAddress?.addressLine2 ?? '');
    _cityController =
        TextEditingController(text: widget.initialAddress?.city ?? '');
    _stateController =
        TextEditingController(text: widget.initialAddress?.state ?? '');
    _postalCodeController =
        TextEditingController(text: widget.initialAddress?.postalCode ?? '');
    _countryController =
        TextEditingController(text: widget.initialAddress?.country ?? '');
    _isDefault = widget.initialAddress?.isDefault ?? false;
  }

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

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = DeliveryAddress(
        id: widget.initialAddress?.id ?? const Uuid().v4(),
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
        isDefault: _isDefault,
      );
      widget.onSave(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialAddress == null
                    ? 'Add New Address'
                    : 'Edit Address',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 16),
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

          // Default address checkbox
          Row(
            children: [
              Checkbox(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
              ),
              const Text('Set as default address'),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Address'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
