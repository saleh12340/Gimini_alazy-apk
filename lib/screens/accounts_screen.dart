import 'package:flutter/material.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  // قائمة تجريبية للعملاء والديون (سيتم ربطها بقاعدة البيانات لاحقاً)
  final List<Map<String, dynamic>> _accounts = [
    {'name': 'أحمد علي', 'amount': 15000, 'phone': '770000000'},
    {'name': 'محمد محسن', 'amount': -5000, 'phone': '730000000'},
    {'name': 'صالح ناصر', 'amount': 25000, 'phone': '710000000'},
  ];

  @override
  Widget build(BuildContext context) {
    // حساب الإجمالي العام للديون
    double totalBalance = _accounts.fold(0, (sum, item) => sum + (item['amount'] as num));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات والديون'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // بطاقة الملخص المالي العلوية
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
          // قائمة العملاء والديون
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // هنا يمكنك لاحقاً إضافة نافذة منبثقة لإضافة عميل جديد
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خاصية إضافة عميل جديد قيد التفعيل')),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
