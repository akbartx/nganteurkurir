import 'package:flutter/material.dart';
import 'package:kurir/screen/dashboard_screen.dart';
import 'package:kurir/screen/login_screen.dart';
import 'package:kurir/screen/register_screen.dart';
import 'package:kurir/screen/detail_order_screen.dart';
import 'package:kurir/screen/detail_orderfood_screen.dart';
import 'package:kurir/screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurir App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      initialRoute: '/driver-splash',
      routes: {
        '/driver-splash': (context) => const SplashScreen(),
        '/driver-login': (context) => LoginScreen(),
        '/driver-register': (context) => RegisterScreen(),
        '/driver-dashboard': (context) => DashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail-order') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DetailOrderScreen(orderId: args['orderId']);
            },
          );
        } else if (settings.name == '/detail-order-food') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DetailOrderFoodScreen(orderId: args['orderId']);
            },
          );
        }
        return null;
      },
    );
  }
}
