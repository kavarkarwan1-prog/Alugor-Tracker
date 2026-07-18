import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

enum _Direction { iqdToUsd, usdToIqd }

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _controller = TextEditingController();
  _Direction _direction = _Direction.iqdToUsd;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Currency Exchange')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<double?>(
          stream: dataService.usdToIqdRateStream,
          builder: (context, snapshot) {
            final rate = snapshot.data;
            final amount = double.tryParse(_controller.text.replaceAll(',', '')) ?? 0;

            double result = 0;
            if (rate != null && rate > 0) {
              result = _direction == _Direction.iqdToUsd ? amount / rate : amount * rate;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rate != null)
                  Text(
                    '1 USD ≈ ${rate.toStringAsFixed(0)} IQD',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 20),
                SegmentedButton<_Direction>(
                  segments: const [
                    ButtonSegment(value: _Direction.iqdToUsd, label: Text('IQD → USD')),
                    ButtonSegment(value: _Direction.usdToIqd, label: Text('USD → IQD')),
                  ],
                  selected: {_direction},
                  onSelectionChanged: (s) => setState(() => _direction = s.first),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: _direction == _Direction.iqdToUsd ? 'Amount in IQD' : 'Amount in USD',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Converted amount'),
                        const SizedBox(height: 6),
                        Text(
                          rate == null
                              ? 'Loading rate...'
                              : '${result.toStringAsFixed(2)} ${_direction == _Direction.iqdToUsd ? 'USD' : 'IQD'}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
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
