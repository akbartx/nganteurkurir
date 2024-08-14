class FoodOrderItem {
  final String productItem;
  final double price;

  FoodOrderItem({
    required this.productItem,
    required this.price,
  });

  factory FoodOrderItem.fromJson(Map<String, dynamic> json) {
    return FoodOrderItem(
      productItem: json['product_item'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
