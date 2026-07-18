import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class CommoditiesScreen extends StatelessWidget {
  const CommoditiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gold, Silver & Diamond')),
      body: StreamBuilder<Map<String, double>>(
        stream: dataService.commoditiesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;

          final items = [
            _CommodityItem('Gold', data['goldPerGramUsd'] ?? 0, 'per gram', Icons.circle,
                const Color(0xFFFFD700)),
            _CommodityItem('Silver', data['silverPerGramUsd'] ?? 0, 'per gram', Icons.circle,
                const Color(0xFFC0C0C0)),
            _CommodityItem('Diamond', data['diamondPerCaratUsd'] ?? 0, 'per carat',
                Icons.diamond, const Color(0xFF9AD4FF)),
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.color.withOpacity(0.2),
                    child: Icon(item.icon, color: item.color),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(item.unit),
                  trailing: Text(
                    '\$${item.priceUsd.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CommodityItem {
  final String name;
  final double priceUsd;
  final String unit;
  final IconData icon;
  final Color color;

  _CommodityItem(this.name, this.priceUsd, this.unit, this.icon, this.color);
}
