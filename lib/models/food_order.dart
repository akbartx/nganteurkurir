import '../item/food_order_item.dart';

class FoodOrder {
  final int id;
  final String transactionId;
  final String userPhone;
  final double estimatedPrice;
  final String storeLocation;
  final String deliveryLocation;
  final int status;
  final List<FoodOrderItem> items;

  FoodOrder({
    required this.id,
    required this.transactionId,
    required this.userPhone,
    required this.estimatedPrice,
    required this.storeLocation,
    required this.deliveryLocation,
    required this.status,
    required this.items,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['id'],
      transactionId: json['transaction_id'],
      userPhone: json['user_phone'],
      estimatedPrice: (json['estimated_price'] ?? 0).toDouble(),
      storeLocation: json['store_location'],
      deliveryLocation: json['delivery_location'],
      status: json['status'],
      items: (json['product_items'] as List<dynamic>?)
          ?.map((item) => FoodOrderItem.fromJson(item))
          .toList() ?? [],
    );
  }

  FoodOrder copyWith({int? status}) {
    return FoodOrder(
      id: this.id,
      transactionId: this.transactionId,
      userPhone: this.userPhone,
      estimatedPrice: this.estimatedPrice,
      storeLocation: this.storeLocation,
      deliveryLocation: this.deliveryLocation,
      status: status ?? this.status,
      items: this.items,
    );
  }
}
