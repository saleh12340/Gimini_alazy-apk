import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
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

class Customer {
  String name;
  String phone;
  double balance;
  Customer({required this.name, required this.phone, this.balance = 0.0});
}

class GroceryProvider extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(name: 'طارق فؤاد الحاج', phone: '771111111', balance: 20650),
    Customer(name: 'صالح العزي', phone: '770000000', balance: 5000),
  ];

  List<Customer> get customers => _customers;

  void addCustomer(String name, String phone) {
    _customers.add(Customer(name: name, phone: phone, balance: 0.0));
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عميل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف / الواتساب'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                Provider.of<GroceryProvider>(context, listen: false)
                    .addCustomer(nameController.text, phoneController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بقالة العزي للمواد الغذائية'),
        centerTitle: true,
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.green),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الهاتف: ${customer.phone}'),
                  trailing: Text(
                    '${customer.balance} ر.ي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: customer.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailScreen(customer: customer),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  Future<void> _sendWhatsAppMessage() async {
    final url = Uri.parse("https://wa.me/967${customer.phone}?text=مرحباً بك يا أخي ${customer.name}، رصيدكم الحالي لدى (بقالة العزي للمواد الغذائية) هو: ${customer.balance} ريال يمني.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حساب العميل: ${customer.name}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الرصيد الحالي:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${customer.balance} ر.ي', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('رقم الواتساب'),
              subtitle: Text(customer.phone),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: _sendWhatsAppMessage,
                  icon: const Icon(Icons.chat),
                  label: const Text('مراسلة كشف الحساب عبر واتساب', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
