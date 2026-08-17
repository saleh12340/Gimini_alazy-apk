import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// سنقوم لاحقاً بإنشاء ملف منفصل لإدارة البيانات
// لكن سنبدأ هنا بتهيئة التطبيق الأساسية
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة SharedPreferences إذا احتجنا لحفظ البيانات محلياً
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        // هنا سنضيف الـ Providers الخاصة بالعملاء والفواتير لاحقاً
        ChangeNotifierProvider(create: (_) => GroceryProvider()),
      ],
      child: const EzziGroceryApp(),
    ),
  );
}

class EzziGroceryApp extends StatelessWidget {
  const EzziGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بقالة العزي',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

// كلاس إدارة البيانات الأساسي
class GroceryProvider extends ChangeNotifier {
  // سنقوم بإضافة وظائف العملاء والفواتير هنا في الخطوة القادمة
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بقالة العزي للمواد الغذائية')),
      body: const Center(
        child: Text('مرحباً بك في تطبيق بقالة العزي - ابدأ بإضافة العملاء'),
      ),
    );
  }
}
