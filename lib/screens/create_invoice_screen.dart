import 'package:flutter/material.dart';

class CreateInvoiceScreen extends StatelessWidget {
  const CreateInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية تحاكي تفاصيل الفاتورة الظاهرة في الصورة
    final String customerName = 'طارق فؤاد الحاج';
    final String date = '2026/8/17';
    
    final List<Map<String, dynamic>> items = [
      {'detail': 'زيت لترين ونص', 'amount': 2400, 'balance': 2400},
      {'detail': 'حوايج', 'amount': 500, 'balance': 2900},
      {'detail': 'هرد', 'amount': 500, 'balance': 3400},
      {'detail': 'رز بسمتي السحاب', 'amount': 3750, 'balance': 7150},
      {'detail': 'شاهي', 'amount': 900, 'balance': 8050},
      {'detail': 'كيس بر الشام', 'amount': 12600, 'balance': 20650},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة والحساب'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // رأس الفاتورة (اسم العميل والتاريخ)
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
                      'العميل : $customerName',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          // جدول تفاصيل المنتجات والديون
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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

          // شريط الإجمالي السفلي
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
                const Text(
                  '20,650 ر.ي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
