import 'package:flutter/material.dart';

void main() {
  runApp(const AlEzziApp());
}

class AlEzziApp extends StatelessWidget {
  const AlEzziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بقالة العزي للمواد الغذائية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F9F6),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بقالة العزي للمواد الغذائية'),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: Colors.amber[700]),
            const SizedBox(height: 20),
            const Text(
              'مرحباً بكم في تطبيق بقالة العزي!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
