import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../services/data_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _amountController = TextEditingController();
  Stock? _selectedStock;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Money → Stock Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Stock>>(
          stream: dataService.stocksStream,
          builder: (context, snapshot) {
            final stocks = snapshot.data ?? [];
            _selectedStock ??= stocks.isNotEmpty ? stocks.first : null;

            if (_selectedStock != null && stocks.isNotEmpty) {
              final match = stocks.where((s) => s.symbol == _selectedStock!.symbol);
              if (match.isNotEmpty) _selectedStock = match.first;
            }

            final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
            final shares = (_selectedStock != null && _selectedStock!.price > 0)
                ? amount / _selectedStock!.price
                : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount in IQD', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. 100000',
                    suffixText: 'IQD',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select stock', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (stocks.isEmpty)
                  const Text('Loading stocks...')
                else
                  DropdownButtonFormField<String>(
                    value: _selectedStock?.symbol,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: stocks
                        .map((s) => DropdownMenuItem(
                              value: s.symbol,
                              child: Text('${s.name} — ${s.price.toStringAsFixed(2)} IQD'),
                            ))
                        .toList(),
                    onChanged: (symbol) {
                      setState(() {
                        _selectedStock = stocks.firstWhere((s) => s.symbol == symbol);
                      });
                    },
                  ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You can buy approximately',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${shares.toStringAsFixed(2)} shares',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        if (_selectedStock != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'of ${_selectedStock!.name} at ${_selectedStock!.price.toStringAsFixed(2)} IQD/share',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
