import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../services/data_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

class StockDetailsScreen extends StatelessWidget {
  final String symbol;
  const StockDetailsScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final favorites = context.watch<FavoritesService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        actions: [
          IconButton(
            icon: Icon(
              favorites.isFavorite(symbol) ? Icons.star_rounded : Icons.star_border_rounded,
              color: favorites.isFavorite(symbol) ? AppColors.brandAccent : null,
            ),
            onPressed: () => favorites.toggle(symbol),
          ),
        ],
      ),
      body: StreamBuilder<List<Stock>>(
        stream: dataService.stocksStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final matches = snapshot.data!.where((s) => s.symbol == symbol);
          if (matches.isEmpty) {
            return const Center(child: Text('Stock not found.'));
          }
          final stock = matches.first;

          final color = stock.isUp
              ? AppColors.priceUp
              : stock.isDown
                  ? AppColors.priceDown
                  : AppColors.neutral;

          final points = stock.history;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    stock.price.toStringAsFixed(2),
                    key: ValueKey(stock.price),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Icon(stock.isUp ? Icons.trending_up : Icons.trending_down, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Price history', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: points.length < 2
                      ? const Center(child: Text('Not enough history yet.'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: const LineTouchData(enabled: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (var i = 0; i < points.length; i++)
                                    FlSpot(i.toDouble(), points[i].price),
                                ],
                                isCurved: true,
                                color: color,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: color.withOpacity(0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
