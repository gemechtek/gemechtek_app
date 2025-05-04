import 'package:flutter/material.dart';

enum ProductColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange;

  @override
  String toString() {
    return switch (this) {
      ProductColor.red => 'Red',
      ProductColor.blue => 'Blue',
      ProductColor.green => 'Green',
      ProductColor.yellow => 'Yellow',
      ProductColor.purple => 'Purple',
      ProductColor.orange => 'Orange',
    };
  }

  String get value => toString();

  static ProductColor fromString(String value) {
    return switch (value) {
      'Red' => ProductColor.red,
      'Blue' => ProductColor.blue,
      'Green' => ProductColor.green,
      'Yellow' => ProductColor.yellow,
      'Purple' => ProductColor.purple,
      'Orange' => ProductColor.orange,
      _ => ProductColor.blue,
    };
  }

  static Color getColorForEnum(ProductColor color) {
    switch (color) {
      case ProductColor.red:
        return Colors.red;
      case ProductColor.blue:
        return Colors.blue;
      case ProductColor.green:
        return Colors.green;
      case ProductColor.yellow:
        return Colors.amber;
      case ProductColor.purple:
        return Colors.purple;
      case ProductColor.orange:
        return Colors.orange;
    }
  }
}
