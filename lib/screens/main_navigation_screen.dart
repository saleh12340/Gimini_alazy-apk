import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

// 2. شاشة الحسابات والديون والعملاء
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  final List<Map<String, dynamic>> _accounts = const [
    {'name': 'أحمد علي', 'amount': 15000, 'phone': '770000000'},
    {'name': 'محمد محسن', 'amount': -5000, 'phone': '730000000'},
    {'name': 'صالح ناصر', 'amount': 25000, 'phone': '710000000'},
    {'name': 'طارق فؤاد الحاج', 'amount': 20650, 'phone': '771111111'},
  ];

  @override
  Widget build(BuildContext context) {
    double totalBalance = _accounts.fold(0, (sum, item) => sum + (item['amount'] as num));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات والديون'),
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
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                final double amount = account['amount'];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.person, color: Colors.green),
                    ),
                    title: Text(
                      account['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('الهاتف: ${account['phone']}'),
                    trailing: Text(
                      '$amount ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: amount >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateInvoiceScreen(customerName: account['name']),
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
    );
  }
}

// 3. شاشة الفواتير وسجل العمليات
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

// 4. شاشة إنشاء وعرض الفاتورة التفصيلية مع الطباعة والـ PDF
class CreateInvoiceScreen extends StatefulWidget {
  final String customerName;
  const CreateInvoiceScreen({super.key, required this.customerName});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> _items = [
    {'detail': 'زيت لترين ونص', 'amount': 2400.0},
    {'detail': 'حوايج', 'amount': 500.0},
    {'detail': 'هرد', 'amount': 500.0},
    {'detail': 'رز بسمتي السحاب', 'amount': 3750.0},
    {'detail': 'شاهي', 'amount': 900.0},
    {'detail': 'كيس بر الشام', 'amount': 12600.0},
  ];

  void _addItem() {
    if (_detailController.text.isEmpty || _amountController.text.isEmpty) return;
    double? parsedAmount = double.tryParse(_amountController.text);
    if (parsedAmount == null) return;

    setState(() {
      _items.add({
        'detail': _detailController.text,
        'amount': parsedAmount,
      });
      _detailController.clear();
      _amountController.clear();
    });
  }

  // دالة الطباعة وتصدير PDF
  Future<void> _printInvoice(double totalBalance) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('بقالة العزي للمواد الغذائية', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('العميل: ${widget.customerName}', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('التاريخ: 2026/8/17', style: const pw.TextStyle(fontSize: 14)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['التفاصيل', 'المبلغ', 'الرصيد'],
                data: _items.map((item) {
                  return [item['detail'].toString(), item['amount'].toString(), ''];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('إجمالي الحساب: $totalBalance ر.ي', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    double runningBalance = 0;
    List<Map<String, dynamic>> processedItems = _items.map((item) {
      runningBalance += (item['amount'] as num);
      return {
        'detail': item['detail'],
        'amount': item['amount'],
        'balance': runningBalance,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('دفتر الفاتورة: ${widget.customerName}'),
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
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'العميل : ${widget.customerName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('2026/8/17', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
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
                      labelText: 'التفاصيل (اسم المنتج)',
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
                      labelText: 'المبلغ (عليه)',
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
                Expanded(flex: 2, child: Text('عليه', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
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
                            const SizedBox(width: 4),
                            const Icon(Icons.circle, size: 10, color: Colors.red),
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

// 5. شاشة المنتجات
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
