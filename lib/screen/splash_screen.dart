import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../token_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    String? token = await TokenService.getToken();
    await Future.delayed(Duration(seconds: 4)); // Simulasi waktu loading
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/driver-login');
    } else {
      Navigator.pushReplacementNamed(context, '/driver-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset('assets/animations/splash_animation.json'),
      ),
    );
  }
}
