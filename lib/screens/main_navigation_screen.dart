import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

// --- نموذج بيانات العميل ---
class Customer {
  String name;
  String phone;
  double balance;
  Customer({required this.name, required this.phone, this.balance = 0.0});
}

// --- نموذج أصناف الفاتورة ---
class InvoiceItem {
  String detail;
  double amount;
  InvoiceItem({required this.detail, required this.amount});
}

// 1. الشاشة الرئيسية للتنقل السفلي
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AccountsScreen(),
    InvoicesScreen(),
    ProductsScreenTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'الحسابات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'الفواتير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'المنتجات',
          ),
        ],
      ),
    );
  }
}

// 2. شاشة الحسابات والديون والعملاء (مع إمكانية إضافة عميل جديد برقم الهاتف)
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final List<Customer> _customers = [
    Customer(name: 'أحمد علي', phone: '770000000', balance: 15000),
    Customer(name: 'محمد محسن', phone: '730000000', balance: -5000),
    Customer(name: 'صالح ناصر', phone: '710000000', balance: 25000),
    Customer(name: 'طارق فؤاد الحاج', phone: '771111111', balance: 20650),
  ];

  void _addNewCustomerDialog(BuildContext context) {
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
              decoration: const InputDecoration(labelText: 'رقم الواتساب (مثال: 771111111)'),
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
                setState(() {
                  _customers.add(Customer(
                    name: nameController.text,
                    phone: phoneController.text,
                    balance: 0.0,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ وإضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalBalance = _customers.fold(0, (sum, item) => sum + item.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات والعملاء'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إجمالي أرصدة الديون:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalBalance ر.ي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: totalBalance >= 0 ? Colors.green.shade700 : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.person, color: Colors.green),
                    ),
                    title: Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewCustomerDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

// 3. شاشة العميل الخاصة (تتيح إرسال واتساب، طباعة كشف الحساب، أو تعديله)
class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  Future<void> _sendWhatsAppMessage() async {
    final url = Uri.parse("https://wa.me/967${customer.phone}?text=مرحباً بك يا أخي ${customer.name}، نود تذكيركم بأن رصيدكم الحالي لدى (بقالة العزي للمواد الغذائية) هو: ${customer.balance} ريال يمني. وشكراً لكم.");
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

// 4. شاشة الفواتير وسجل العمليات
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفواتير والمبيعات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt, color: Colors.blue, size: 36),
              title: const Text('فاتورة العميل: طارق فؤاد الحاج', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('التاريخ: 2026/8/17 - الإجمالي: 20,650 ر.ي'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateInvoiceScreen(customerName: 'طارق فؤاد الحاج'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvoiceScreen(customerName: 'عميل جديد'),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 5. شاشة إنشاء وعرض الفاتورة التفصيلية وتعديل اسم العميل مع الطابعة الحرارية والـ PDF
class CreateInvoiceScreen extends StatefulWidget {
  final String customerName;
  const CreateInvoiceScreen({super.key, required this.customerName});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late TextEditingController _nameController;
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<InvoiceItem> _items = [
    InvoiceItem(detail: 'زيت لترين ونص', amount: 2400.0),
    InvoiceItem(detail: 'حوايج', amount: 500.0),
    InvoiceItem(detail: 'هرد', amount: 500.0),
    InvoiceItem(detail: 'رز بسمتي السحاب', amount: 3750.0),
    InvoiceItem(detail: 'شاهي', amount: 900.0),
    InvoiceItem(detail: 'كيس بر الشام', amount: 12600.0),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customerName);
  }

  void _addItem() {
    if (_detailController.text.isEmpty || _amountController.text.isEmpty) return;
    double? parsedAmount = double.tryParse(_amountController.text);
    if (parsedAmount == null) return;

    setState(() {
      _items.add(InvoiceItem(
        detail: _detailController.text,
        amount: parsedAmount,
      ));
      _detailController.clear();
      _amountController.clear();
    });
  }

  Future<void> _printInvoice(double totalBalance) async {
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
                  child: pw.Text('فاتورة مبيعات نقدية / أُجل', style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Divider(),
                pw.Text('العميل: ${_nameController.text}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                pw.Text('التاريخ: 2026/8/17', style: pw.TextStyle(font: font, fontSize: 9)),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  context: context,
                  cellStyle: pw.TextStyle(font: font, fontSize: 9),
                  headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
                  headers: ['التفاصيل', 'المبلغ'],
                  data: _items.map((item) {
                    return [item.detail, item.amount.toString()];
                  }).toList(),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي المطلوب:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    pw.Text('$totalBalance ر.ي', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('شكراً لتعاملكم معنا', style: pw.TextStyle(font: font, fontSize: 8))),
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
    double runningBalance = 0;
    List<Map<String, dynamic>> processedItems = _items.map((item) {
      runningBalance += item.amount;
      return {
        'detail': item.detail,
        'amount': item.amount,
        'balance': runningBalance,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحرير فاتورة جديدة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printInvoice(runningBalance),
            tooltip: 'طباعة / تصدير PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العميل في رأس الفاتورة',
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _detailController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الصنف أو التفاصيل',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 38),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('التفاصيل', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('الرصيد التراكمي', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: processedItems.length,
              itemBuilder: (context, index) {
                final item = processedItems[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item['detail'],
                          style: const TextStyle(fontSize: 15),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item['amount']}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${item['balance']}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إجمالي الحساب المطلوب:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$runningBalance ر.ي',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 6. شاشة المنتجات
class ProductsScreenTab extends StatelessWidget {
  const ProductsScreenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المنتجات'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('قسم إدارة المنتجات والأسعار', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
