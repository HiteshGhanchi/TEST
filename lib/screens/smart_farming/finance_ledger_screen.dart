import 'package:flutter/material.dart';

final Color _primaryGreen = Colors.green.shade700;
final Color _expenseRed = Colors.red.shade700;
final Color _incomeGreen = Colors.green.shade600;

class FinanceLedgerScreen extends StatelessWidget {
  const FinanceLedgerScreen({super.key});

  // Mock transaction data
  final List<Map<String, dynamic>> _transactions = const [
    {'title': 'Corn Seed Purchase', 'date': 'Oct 28, 2023', 'amount': -1250.00, 'icon': Icons.agriculture, 'color': Colors.red},
    {'title': 'Soybean Sale - Lot A', 'date': 'Oct 26, 2023', 'amount': 7800.00, 'icon': Icons.grain, 'color': Colors.green},
    {'title': 'Tractor Fuel', 'date': 'Oct 25, 2023', 'amount': -185.50, 'icon': Icons.local_gas_station, 'color': Colors.red},
    {'title': 'Fertilizer Purchase', 'date': 'Oct 22, 2023', 'amount': -2300.00, 'icon': Icons.science, 'color': Colors.red},
    {'title': 'Wheat Sale - Lot B', 'date': 'Oct 20, 2023', 'amount': 5100.00, 'icon': Icons.grain, 'color': Colors.green},
  ];

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // Updated from withOpacity
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Balance', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            '\$15,750.00',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Income', '\$25,200', Icons.arrow_upward, _incomeGreen),
              _buildMetric('Expenses', '\$9,450', Icons.arrow_downward, _expenseRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final bool isExpense = transaction['amount'] < 0;
    final Color amountColor = isExpense ? _expenseRed : _incomeGreen;
    final String sign = isExpense ? '-' : '+';
    final String formattedAmount = '\$${transaction['amount'].abs().toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
          radius: 28,
          child: Icon(transaction['icon'] as IconData, color: isExpense ? Colors.red.shade700 : _incomeGreen, size: 28),
        ),
        title: Text(transaction['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(transaction['date'] as String, style: const TextStyle(color: Colors.grey)),
        trailing: Text(
          '$sign$formattedAmount',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Farm Finance Ledger', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context),
                
                // Filter and Search
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'This Month',
                            items: <String>['This Month', 'Last Month', 'This Year']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: _primaryGreen),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              // Handle date filter change
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Transaction Tabs
                Row(
                  children: [
                    _buildTabButton('All', true),
                    _buildTabButton('Income', false),
                    _buildTabButton('Expenses', false),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Transactions
                const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._transactions.map(_buildTransactionTile),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
          
          // Floating Action Button for New Transaction
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: _primaryGreen,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabButton(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: _primaryGreen,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
        onSelected: (selected) {
          // Implement tab selection logic
        },
      ),
    );
  }
}