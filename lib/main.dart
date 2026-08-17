import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
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

// نموذج بيانات العميل
class Customer {
  String name;
  String phone;
  double balance;
  Customer({required this.name, required this.phone, this.balance = 0.0});
}

// كلاس إدارة البيانات (Provider)
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

// الشاشة الرئيسية لإدارة العملاء
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

// شاشة تفاصيل العميل مع خيارات الطباعة والواتساب
class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  Future<void> _sendWhatsAppMessage() async {
    final url = Uri.parse("https://wa.me/967${customer.phone}?text=مرحباً بك يا أخي ${customer.name}، رصيدكم الحالي لدى (بقالة العزي للمواد الغذائية) هو: ${customer.balance} ريال يمني.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _printCustomerStatement() async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('بقالة العزي للمواد الغذائية', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                ),
                pw.Center(
                  child: pw.Text('كشف حساب عميل', style: pw.TextStyle(font: font, fontSize: 10)),
                ),
                pw.Divider(),
                pw.Text('اسم العميل: ${customer.name}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                pw.Text('رقم الهاتف: ${customer.phone}', style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الرصيد الإجمالي:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('${customer.balance} ر.ي', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Center(child: pw.Text('شكراً لتعاملكم معنا', style: pw.TextStyle(font: font, fontSize: 9))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: _sendWhatsAppMessage,
                  icon: const Icon(Icons.chat),
                  label: const Text('مراسلة واتساب'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: _printCustomerStatement,
                  icon: const Icon(Icons.print),
                  label: const Text('طباعة الكشف'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
