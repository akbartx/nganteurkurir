import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List transactions = [];
  List foodOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
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

    // Fetch courier orders
    final courierResponse = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Fetch food orders
    final foodResponse = await http.get(
      Uri.parse('http://192.168.1.13:5006/api/food-orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (courierResponse.statusCode == 200 && foodResponse.statusCode == 200) {
      final courierData = json.decode(courierResponse.body);
      final foodData = json.decode(foodResponse.body);
      setState(() {
        transactions = courierData;
        foodOrders = foodData;
      });
    } else {
      print('Failed to fetch transactions');
      print('Courier response: ${courierResponse.statusCode}, ${courierResponse.body}');
      print('Food response: ${foodResponse.statusCode}, ${foodResponse.body}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateTransactionStatus(int id, int status, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('Token not found');
      Navigator.pushReplacementNamed(context, '/driver-login');
      return;
    }

    final response = await http.put(
      Uri.parse(type == 'kurir'
          ? 'http://192.168.1.13:5006/api/orders/status'
          : 'http://192.168.1.13:5006/api/food-orders/status'),
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
      _fetchTransactions();
    } else {
      print('Failed to update transaction status');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/driver-login');
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchTransactions,
          child: (transactions.isEmpty && foodOrders.isEmpty)
              ? Center(child: Text('No transactions found'))
              : ListView.builder(
            itemCount: transactions.length + foodOrders.length,
            itemBuilder: (context, index) {
              if (index < transactions.length) {
                return _buildTransactionCard(transactions[index], 'kurir');
              } else {
                return _buildTransactionCard(
                    foodOrders[index - transactions.length], 'food');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(dynamic transaction, String type) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(transaction['recipient_address'] ?? transaction['delivery_location']),
        subtitle: Text(transaction['recipient_phone'] ?? transaction['user_phone']),
        trailing: IconButton(
          icon: Icon(
            transaction['status'] == 0 ? Icons.pending : Icons.check_circle,
            color: transaction['status'] == 0 ? Colors.red : Colors.green,
          ),
          onPressed: () {
            _updateTransactionStatus(
              transaction['id'],
              transaction['status'] == 0 ? 1 : 0,
              type,
            );
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            type == 'kurir' ? '/detail-order' : '/detail-order-food',
            arguments: {
              'orderId': transaction['id'],
            },
          );
        },
      ),
    );
  }
}
