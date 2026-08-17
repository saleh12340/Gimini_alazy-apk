import 'package:flutter/material.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final String customerName = 'طارق فؤاد الحاج';
  final String date = '2026/8/17';

  // متحكمات حقول الإدخال لإضافة بند جديد
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // قائمة البنود الحالية
  final List<Map<String, dynamic>> _items = [
    {'detail': 'زيت لترين ونص', 'amount': 2400},
    {'detail': 'حوايج', 'amount': 500},
    {'detail': 'هرد', 'amount': 500},
    {'detail': 'رز بسمتي السحاب', 'amount': 3750},
    {'detail': 'شاهي', 'amount': 900},
    {'detail': 'كيس بر الشام', 'amount': 12600},
  ];

  // دالة لإضافة بند جديد وحساب الرصيد التراكمي
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

  @override
  Widget build(BuildContext context) {
    // حساب الرصيد التراكمي تدريجياً وإجمالي الحساب
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
        title: const Text('إنشاء وعرض الفاتورة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // رأس الفاتورة
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

          // نموذج إدخال بند جديد (التفاصيل والمبلغ)
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
                      labelText: 'المبلغ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 36),
                ),
              ],
            ),
          ),

          // ترويسة الجدول
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

          // قائمة البنود والأسعار
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
