import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/food_order.dart';
import '../services/food_order_service.dart';

class DetailOrderFoodScreen extends StatefulWidget {
  final int orderId;

  DetailOrderFoodScreen({required this.orderId});

  @override
  _DetailOrderFoodScreenState createState() => _DetailOrderFoodScreenState();
}

class _DetailOrderFoodScreenState extends State<DetailOrderFoodScreen> {
  FoodOrder? order;
  bool _isLoading = true;
  final FoodOrderService _foodOrderService = FoodOrderService();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail(widget.orderId);
  }

  Future<void> _fetchOrderDetail(int id) async {
    try {
      final fetchedOrder = await _foodOrderService.fetchOrderDetail(id);
      setState(() {
        order = fetchedOrder;
        _isLoading = false;
      });
      print('Fetched order: ${order}');
      print('Product items: ${order?.items}');
    } catch (e) {
      print('Failed to fetch order detail: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateOrderStatus(int status) async {
    if (order != null) {
      final success = await _foodOrderService.updateOrderStatus(order!.id, status);
      if (success) {
        setState(() {
          order = order!.copyWith(status: status);
        });
        // Show toast on success
        Fluttertoast.showToast(
          msg: status == 0 ? "Order dibatalkan" : "Order diambil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Gagal memperbarui status order",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Failed to update order status');
      }
    }
  }

  void _launchMaps() async {
    if (order != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${order!.deliveryLocation}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan Makanan'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : order == null
          ? Center(child: Text('Tidak ada order ditampilkan'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ID Pesanan: ${order!.id}'),
            Text('Transaction ID: ${order!.transactionId}'),
            Text('Nomor HP Penerima: ${order!.userPhone}'),
            Text('Harga Estimasi: ${order!.estimatedPrice}'),
            Text('Alamat Pengambilan: ${order!.storeLocation}'),
            Text('Alamat Pengantaran: ${order!.deliveryLocation}'),
            Text('Status: ${order!.status}'),
            SizedBox(height: 10),
            Text('Pesanan Produk:'),
            ...order!.items.map<Widget>((item) {
              return ListTile(
                title: Text(item.productItem),
                subtitle: Text('Harga: ${item.price.toString()}'),
              );
            }).toList(),
            SizedBox(height: 10),
            Text('Total Harga: ${order!.estimatedPrice.toString()}'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _launchMaps,
              child: Text('Lihat di Peta'),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(0),
                    child: Text('Batalkan'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(1),
                    child: Text('Ambil'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
