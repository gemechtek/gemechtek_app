import 'package:flutter/material.dart';

import 'package:spark_aquanix/backend/model/order_model.dart';

class AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio button or checkmark icon
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: Colors.blue,
              ),
              // Address details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${address.phoneNumber}, ${address.addressLine1}"),
                    const SizedBox(height: 2),
                    Text(
                      '${address.city}, ${address.state} ${address.postalCode}',
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
