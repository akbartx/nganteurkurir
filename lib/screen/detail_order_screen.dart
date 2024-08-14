import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maps_launcher/maps_launcher.dart';

class DetailOrderScreen extends StatefulWidget {
  final int orderId;

  DetailOrderScreen({required this.orderId});

  @override
  _DetailOrderScreenState createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  Map<String, dynamic>? orderDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      Navigator.pushReplacementNamed(context, '/driver-login');
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/orders/${widget.orderId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data: $data');  // Tambahkan ini untuk memeriksa data
      if (data is List && data.isNotEmpty) {
        setState(() {
          orderDetails = data[0];
        });
      } else {
        print('Invalid data format');
      }
    } else {
      print('Failed to fetch order details');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateTransactionStatus(int id, int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      Navigator.pushReplacementNamed(context, '/driver-login');
      return;
    }

    final response = await http.put(
      Uri.parse('http://192.168.1.13:5006/api/api/orders/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id': id,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      print('Transaction status updated');
      _fetchOrderDetails();
    } else {
      print('Failed to update transaction status');
    }
  }

  void _openGoogleMaps(String pickupAddress) {
    final latLng = pickupAddress.split(',');
    if (latLng.length == 2) {
      final lat = double.parse(latLng[0].trim());
      final lng = double.parse(latLng[1].trim());
      MapsLauncher.launchCoordinates(lat, lng);
    } else {
      print('Invalid lat/lng format');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Order'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushReplacementNamed(context, '/driver-login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : orderDetails == null
          ? Center(child: Text('Failed to load order details'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Alamat Penerima: ${orderDetails!['recipient_address']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'No Penerima: ${orderDetails!['recipient_phone']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${orderDetails!['status'] == 0 ? 'Pending' : 'Selesai'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            if (orderDetails!['pickup_address'] != null)
              Text(
                'Pickup Address: ${orderDetails!['pickup_address']}',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _updateTransactionStatus(widget.orderId, 1);
              },
              child: Text('Ambil'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _updateTransactionStatus(widget.orderId, 0);
              },
              child: Text('Batal'),
            ),
            SizedBox(height: 20),
            if (orderDetails!['pickup_address'] != null)
              ElevatedButton(
                onPressed: () {
                  _openGoogleMaps(orderDetails!['pickup_address']);
                },
                child: Text('Buka di Google Maps'),
              ),
          ],
        ),
      ),
    );
  }
}
