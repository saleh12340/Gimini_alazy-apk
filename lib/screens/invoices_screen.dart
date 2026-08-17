import 'package:flutter/material.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // قائمة تجريبية للفواتير المسجلة
  final List<Map<String, dynamic>> _invoices = [
    {'id': '#101', 'customer': 'طارق فؤاد الحاج', 'total': 20650, 'date': '2026-08-17'},
    {'id': '#102', 'customer': 'محمد محسن', 'total': 12000, 'date': '2026-08-16'},
    {'id': '#103', 'customer': 'أحمد علي', 'total': 4500, 'date': '2026-08-16'},
  ];

  @override
  Widget build(BuildContext context) {
    // حساب إجمالي مبيعات الفواتير
    double totalSales = _invoices.fold(0, (sum, item) => sum + (item['total'] as num));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفواتير والمبيعات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // بطاقة إجمالي المبيعات العلوية
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إجمالي المبيعات المسجلة:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalSales ر.ي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          // قائمة الفواتير
          Expanded(
            child: ListView.builder(
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final invoice = _invoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.receipt, color: Colors.blue),
                    ),
                    title: Text(
                      'فاتورة رقم: ${invoice['id']} - ${invoice['customer']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('التاريخ: ${invoice['date']}'),
                    trailing: Text(
                      '${invoice['total']} ر.ي',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // فتح صفحة تفاصيل الفاتورة عند النقر عليها
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateInvoiceScreen(),
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
        onPressed: () {
          // الانتقال إلى شاشة إنشاء فاتورة جديدة عند الضغط على الزر
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvoiceScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
