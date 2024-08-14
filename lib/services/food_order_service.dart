import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodOrderService {
  Future<FoodOrder?> fetchOrderDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/food-orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      print('Fetched data: $data');
      return FoodOrder.fromJson(data);
    } else {
      throw Exception('Failed to fetch order detail');
    }
  }

  Future<bool> updateOrderStatus(int id, int status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('http://192.168.1.13:5006/api/food-orders/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id': id,
        'status': status,
      }),
    );

    return response.statusCode == 200;
  }
}
