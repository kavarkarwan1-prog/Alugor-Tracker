import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock.dart';
import '../services/data_service.dart';
import '../services/favorites_service.dart';
import '../widgets/stock_tile.dart';
import 'stock_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final favorites = context.watch<FavoritesService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<Stock>>(
        stream: dataService.stocksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stocks = (snapshot.data ?? [])
              .where((s) => favorites.isFavorite(s.symbol))
              .toList();

          if (stocks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet. Tap the star on any stock to add it here.',
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
                isFavorite: true,
                onToggleFavorite: () => favorites.toggle(stock.symbol),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StockDetailsScreen(symbol: stock.symbol)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
