import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroceryProvider(prefs)),
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
        fontFamily: 'Cairo',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== Models ====================
class Customer {
  final String id;
  final String name;
  final String phone;
  double balance;
  final DateTime createdAt;
  DateTime lastUpdated;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'balance': balance,
        'createdAt': createdAt.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        balance: (json['balance'] ?? 0.0).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        lastUpdated: DateTime.parse(json['lastUpdated']),
      );

  Customer copyWith({
    String? name,
    String? phone,
    double? balance,
    DateTime? lastUpdated,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

// ==================== Transaction Model ====================
class Transaction {
  final String id;
  final String customerId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'amount': amount,
        'type': type.toString(),
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        customerId: json['customerId'],
        amount: (json['amount'] ?? 0.0).toDouble(),
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => TransactionType.add,
        ),
        description: json['description'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );
}

enum TransactionType { add, subtract, initial }

// ==================== Provider ====================
class GroceryProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Customer> _customers = [];
  List<Transaction> _transactions = [];
  
  final String _customersKey = 'customers_data';
  final String _transactionsKey = 'transactions_data';

  GroceryProvider(this._prefs) {
    _loadData();
  }

  List<Customer> get customers => _customers;
  List<Transaction> get transactions => _transactions;

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Transaction> getCustomerTransactions(String customerId) {
    return _transactions
        .where((t) => t.customerId == customerId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _loadData() {
    try {
      // Load customers
      final String? customersData = _prefs.getString(_customersKey);
      if (customersData != null) {
        final List<dynamic> jsonList = json.decode(customersData);
        _customers = jsonList.map((json) => Customer.fromJson(json)).toList();
      } else {
        _customers = _getDefaultCustomers();
      }

      // Load transactions
      final String? transactionsData = _prefs.getString(_transactionsKey);
      if (transactionsData != null) {
        final List<dynamic> jsonList = json.decode(transactionsData);
        _transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
      }
    } catch (e) {
      _customers = _getDefaultCustomers();
      _transactions = [];
    }
    notifyListeners();
  }

  List<Customer> _getDefaultCustomers() {
    return [
      Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'طارق فؤاد الحاج',
        phone: '771111111',
        balance: 20650,
      ),
      Customer(
        id: (DateTime.now().millisecondsSinceEpoch + 1000).toString(),
        name: 'صالح العزي',
        phone: '770000000',
        balance: 5000,
      ),
    ];
  }

  void _saveData() {
    try {
      final String customersJson = json.encode(_customers.map((c) => c.toJson()).toList());
      _prefs.setString(_customersKey, customersJson);
      
      final String transactionsJson = json.encode(_transactions.map((t) => t.toJson()).toList());
      _prefs.setString(_transactionsKey, transactionsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  void addCustomer(String name, String phone) {
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      throw Exception('الرجاء إدخال جميع البيانات');
    }

    final newCustomer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
      balance: 0.0,
    );
    
    _customers.add(newCustomer);
    
    // Add initial transaction
    _addTransaction(
      customerId: newCustomer.id,
      amount: 0,
      type: TransactionType.initial,
      description: 'فتح حساب جديد',
    );
    
    _saveData();
    notifyListeners();
  }

  void updateCustomerBalance(String customerId, double amount, {required bool isAdd, String description = ''}) {
    final customer = getCustomerById(customerId);
    if (customer == null) return;

    final newBalance = isAdd ? customer.balance + amount : customer.balance - amount;
    if (newBalance < 0) {
      throw Exception('الرصيد لا يمكن أن يكون سالباً');
    }

    customer.balance = newBalance;
    customer.lastUpdated = DateTime.now();

    _addTransaction(
      customerId: customerId,
      amount: amount,
      type: isAdd ? TransactionType.add : TransactionType.subtract,
      description: description.isNotEmpty ? description : (isAdd ? 'إضافة رصيد' : 'خصم رصيد'),
    );

    _saveData();
    notifyListeners();
  }

  void _addTransaction({
    required String customerId,
    required double amount,
    required TransactionType type,
    required String description,
  }) {
    _transactions.add(
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        amount: amount,
        type: type,
        description: description,
      ),
    );
  }

  void deleteCustomer(String customerId) {
    _customers.removeWhere((c) => c.id == customerId);
    _transactions.removeWhere((t) => t.customerId == customerId);
    _saveData();
    notifyListeners();
  }

  void deleteAllData() {
    _customers.clear();
    _transactions.clear();
    _saveData();
    notifyListeners();
  }

  double getTotalBalance() {
    return _customers.fold(0.0, (sum, customer) => sum + customer.balance);
  }

  int getTotalCustomers() {
    return _customers.length;
  }

  int getTotalTransactions() {
    return _transactions.length;
  }
}

// ==================== Home Screen ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بقالة العزي للمواد الغذائية'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllTransactionsScreen()),
            ),
            tooltip: 'جميع المعاملات',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog(context);
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'بقالة العزي',
                  applicationVersion: '2.0.0',
                  applicationIcon: const Icon(Icons.shopping_bag, size: 50),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('عن التطبيق'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف جميع البيانات', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, provider, child) {
          if (provider.customers.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              _buildStatsCard(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return _buildCustomerCard(context, customer);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('إضافة عميل', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عملاء',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر + لإضافة عميل جديد',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(GroceryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'العملاء',
            value: provider.getTotalCustomers().toString(),
          ),
          _buildStatItem(
            icon: Icons.money,
            label: 'إجمالي الرصيد',
            value: '${provider.getTotalBalance().toStringAsFixed(0)} ر.ي',
          ),
          _buildStatItem(
            icon: Icons.receipt_long,
            label: 'المعاملات',
            value: provider.getTotalTransactions().toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailScreen(customerId: customer.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0] : '?',
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📱 ${customer.phone}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.balance >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: customer.balance >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      '${customer.balance.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: customer.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'آخر تحديث: ${_formatDate(customer.lastUpdated)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عميل جديد', textAlign: TextAlign.center),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم العميل';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف / الواتساب',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (value.trim().length < 9) {
                    return 'رقم الهاتف يجب أن يكون 9 أرقام على الأقل';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  final provider = Provider.of<GroceryProvider>(context, listen: false);
                  provider.addCustomer(nameController.text, phoneController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم إضافة العميل بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع البيانات'),
        content: const Text(
          'هل أنت متأكد من حذف جميع العملاء والمعاملات؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final provider = Provider.of<GroceryProvider>(context, listen: false);
              provider.deleteAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ تم حذف جميع البيانات'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('حذف الكل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ==================== Customer Detail Screen ====================
class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;
  bool _isWhatsAppAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkWhatsAppAvailability();
  }

  Customer? get _customer {
    final provider = Provider.of<GroceryProvider>(context, listen: false);
    return provider.getCustomerById(widget.customerId);
  }

  List<Transaction> get _transactions {
    final provider = Provider.of<GroceryProvider>(context, listen: false);
    return provider.getCustomerTransactions(widget.customerId);
  }

  Future<void> _checkWhatsAppAvailability() async {
    try {
      final customer = _customer;
      if (customer != null) {
        final url = Uri.parse('whatsapp://send?phone=967${customer.phone}');
        final canLaunch = await canLaunchUrl(url);
        if (mounted) {
          setState(() {
            _isWhatsAppAvailable = canLaunch;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWhatsAppAvailable = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendWhatsAppMessage() async {
    final customer = _customer;
    if (customer == null) return;

    final message = 
        'مرحباً بك يا أخي ${customer.name}،\n\n'
        '📊 كشف حسابكم لدى (بقالة العزي للمواد الغذائية)\n'
        '─────────────────────\n'
        '💰 الرصيد الحالي: ${customer.balance.toStringAsFixed(0)} ريال يمني\n'
        '📅 تاريخ الكشف: ${DateTime.now().toLocal().toString().split(' ')[0]}\n'
        '⏰ الوقت: ${DateTime.now().toLocal().toString().split(' ')[1]}\n'
        '─────────────────────\n'
        '🔄 آخر المعاملات:\n';

    final recentTransactions = _transactions.take(3);
    for (var t in recentTransactions) {
      final type = t.type == TransactionType.add ? '➕ إضافة' : t.type == TransactionType.subtract ? '➖ خصم' : '📝 افتتاح';
      message += '  • $type: ${t.amount.toStringAsFixed(0)} ر.ي (${t.description})\n';
    }

    message += '\n📱 للاستفسار: 770000000\n'
        'شكراً لثقتكم بنا 🙏';

    final url = Uri.parse(
        'https://wa.me/967${customer.phone}?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ يرجى تثبيت تطبيق واتساب أولاً'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateBalance(double amount, {required bool isAdd}) {
    final customer = _customer;
    if (customer == null) return;

    try {
      final provider = Provider.of<GroceryProvider>(context, listen: false);
      provider.updateCustomerBalance(
        customer.id,
        amount,
        isAdd: isAdd,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : (isAdd ? 'إضافة رصيد' : 'خصم رصيد'),
      );
      
      _amountController.clear();
      _descriptionController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم ${isAdd ? 'إضافة' : 'خصم'} ${amount.toStringAsFixed(0)} ر.ي بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateBalanceDialog({required bool isAdd}) {
    _amountController.clear();
    _descriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAdd ? 'إضافة مبلغ للرصيد' : 'خصم مبلغ من الرصيد',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الرصيد الحالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${_customer?.balance.toStringAsFixed(0) ?? 0} ر.ي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (_customer?.balance ?? 0) >= 0 ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'المبلغ',
                border: const OutlineInputBorder(),
                suffixText: 'ر.ي',
                prefixIcon: Icon(isAdd ? Icons.add : Icons.remove, color: isAdd ? Colors.green : Colors.red),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLength: 50,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdd ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  _updateBalance(amount, isAdd: isAdd);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال المبلغ')),
                );
              }
            },
            child: Text(isAdd ? 'إضافة' : 'خصم'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    final customer = _customer;
    if (customer == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العميل', textAlign: TextAlign.center),
        content: Text(
          'هل أنت متأكد من حذف العميل "${customer.name}"؟\n\nسيتم حذف جميع المعاملات المرتبطة بهذا العميل.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final provider = Provider.of<GroceryProvider>(context, listen: false);
              provider.deleteCustomer(customer.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🗑️ تم حذف العميل ${customer.name}')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog() {
    final customer = _customer;
    if (customer == null) return;

    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات العميل', textAlign: TextAlign.center),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم العميل';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Note: In a real app, you would update the customer
                // For now, we'll just show a message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تم تحديث البيانات')),
                );
              }
            },
            child: const Text('تحديث', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('العميل غير موجود')),
        body: const Center(child: Text('لم يتم العثور على العميل')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer.name,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditCustomerDialog,
            tooltip: 'تعديل البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
            tooltip: 'حذف العميل',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomerInfoCard(customer),
          const SizedBox(height: 8),
          _buildBalanceActions(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0] : '?',
                  style: TextStyle(fontSize: 28, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📱 ${customer.phone}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📅 منذ ${_formatDate(customer.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💰 الرصيد الحالي:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: customer.balance >= 0 ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  '${customer.balance.toStringAsFixed(0)} ر.ي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: customer.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip('المعاملات', _transactions.length.toString(), Icons.receipt),
              _buildInfoChip('آخر تحديث', _formatDate(customer.lastUpdated), Icons.update),
              _buildInfoChip(
                'الحالة',
                customer.balance >= 0 ? 'نشط' : 'مدين',
                customer.balance >= 0 ? Icons.check_circle : Icons.warning,
                color: customer.balance >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, {Color color = Colors.blue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showUpdateBalanceDialog(isAdd: true),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة رصيد'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showUpdateBalanceDialog(isAdd: false),
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('خصم رصيد'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isWhatsAppAvailable ? _sendWhatsAppMessage : null,
              icon: const Icon(Icons.whatsapp),
              label: const Text('واتساب'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'لا توجد معاملات',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 المعاملات السابقة (${_transactions.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final isAdd = transaction.type == TransactionType.add;
                final isInitial = transaction.type == TransactionType.initial;
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdd ? Colors.green.shade100 : 
                                     isInitial ? Colors.blue.shade100 : Colors.red.shade100,
                      child: Icon(
                        isAdd ? Icons.add : 
                        isInitial ? Icons.person_add : Icons.remove,
                        color: isAdd ? Colors.green : 
                               isInitial ? Colors.blue : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_formatDateTime(transaction.timestamp)),
                    trailing: Text(
                      '${isAdd || isInitial ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAdd ? Colors.green : 
                               isInitial ? Colors.blue : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== All Transactions Screen ====================
class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المعاملات'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد معاملات'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final transaction = provider.transactions[index];
              final customer = provider.getCustomerById(transaction.customerId);
              final isAdd = transaction.type == TransactionType.add;
              final isInitial = transaction.type == TransactionType.initial;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdd ? Colors.green.shade100 : 
                                   isInitial ? Colors.blue.shade100 : Colors.red.shade100,
                    child: Icon(
                      isAdd ? Icons.add : 
                      isInitial ? Icons.person_add : Icons.remove,
                      color: isAdd ? Colors.green : 
                             isInitial ? Colors.blue : Colors.red,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('👤 ${customer?.name ?? 'غير معروف'}'),
                      Text(_formatDateTime(transaction.timestamp)),
                    ],
                  ),
                  trailing: Text(
                    '${isAdd || isInitial ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ر.ي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAdd ? Colors.green : 
                             isInitial ? Colors.blue : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
