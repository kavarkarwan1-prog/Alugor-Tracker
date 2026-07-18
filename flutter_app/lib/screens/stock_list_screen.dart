import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../services/data_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stock_tile.dart';
import '../widgets/last_updated_bar.dart';
import 'stock_details_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final favorites = context.watch<FavoritesService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ISX Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => context.read<ThemeController>().toggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<DateTime?>(
            stream: dataService.lastUpdatedStream,
            builder: (context, snap) => LastUpdatedBar(lastUpdated: snap.data),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search stocks...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<Stock>>(
              stream: dataService.stocksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final stocks = (snapshot.data ?? [])
                    .where((s) =>
                        _query.isEmpty ||
                        s.name.toLowerCase().contains(_query) ||
                        s.symbol.toLowerCase().contains(_query))
                    .toList();

                if (stocks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No stocks yet. The scraper runs on a schedule - '
                        'check back shortly, or trigger the workflow manually.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, i) {
                    final stock = stocks[i];
                    return StockTile(
                      stock: stock,
                      isFavorite: favorites.isFavorite(stock.symbol),
                      onToggleFavorite: () => favorites.toggle(stock.symbol),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StockDetailsScreen(symbol: stock.symbol),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
