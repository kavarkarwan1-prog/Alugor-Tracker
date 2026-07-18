class StockHistoryPoint {
  final double price;
  final DateTime timestamp;

  StockHistoryPoint({required this.price, required this.timestamp});

  factory StockHistoryPoint.fromJson(Map<String, dynamic> json) {
    return StockHistoryPoint(
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class Stock {
  final String symbol;
  final String name;
  final double price;
  final double previousPrice;
  final double change;
  final double changePercent;
  final String direction; // 'up' | 'down' | 'flat'
  final List<StockHistoryPoint> history;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.previousPrice,
    required this.change,
    required this.changePercent,
    required this.direction,
    required this.history,
  });

  bool get isUp => direction == 'up';
  bool get isDown => direction == 'down';

  factory Stock.fromJson(Map<String, dynamic> json) {
    final historyJson = (json['history'] as List<dynamic>? ?? []);
    return Stock(
      symbol: (json['symbol'] ?? '').toString(),
      name: (json['name'] ?? json['symbol'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (json['previousPrice'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      direction: (json['direction'] ?? 'flat').toString(),
      history: historyJson
          .map((e) => StockHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
