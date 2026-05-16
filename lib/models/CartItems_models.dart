import 'package:food_app/models/Product_models.dart';

class CartItem {
  final Product product;
  final ProductSize selectedSize;
  final List<Addon> selectedAddons;

  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.quantity,
    this.selectedAddons = const [],
  });

  int get addonTotal =>
      selectedAddons.fold(
        0,
        (sum, addon) => sum + addon.price,
      );

  int get unitPrice =>
      selectedSize.price + addonTotal;

  int get totalPrice =>
      unitPrice * quantity;
}