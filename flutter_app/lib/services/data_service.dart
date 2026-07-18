import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

/// Polls the static JSON files published on GitHub Pages (written by the
/// GitHub Actions scraper workflow) every 60 seconds and exposes the
/// results as broadcast streams, mirroring the shape the app previously
/// got from Firestore snapshots - so screens barely had to change.
///
/// Each stream replays its most recent value to new subscribers (so a
/// screen pushed later, e.g. stock details, doesn't have to wait a full
/// 60s for its first value).
class DataService {
  DataService({required this.baseUrl});

  /// Base URL of the published GitHub Pages site, no trailing slash.
  /// e.g. https://yourname.github.io/isx-tracker
  final String baseUrl;

  Timer? _timer;
  final _client = http.Client();

  final _stocksController = StreamController<List<Stock>>.broadcast();
  final _lastUpdatedController = StreamController<DateTime?>.broadcast();
  final _usdToIqdController = StreamController<double?>.broadcast();
  final _commoditiesController = StreamController<Map<String, double>>.broadcast();

  List<Stock> _latestStocks = [];
  DateTime? _latestUpdated;
  double? _latestUsdToIqd;
  Map<String, double> _latestCommodities = {};

  Stream<List<Stock>> get stocksStream async* {
    yield _latestStocks;
    yield* _stocksController.stream;
  }

  Stream<DateTime?> get lastUpdatedStream async* {
    yield _latestUpdated;
    yield* _lastUpdatedController.stream;
  }

  Stream<double?> get usdToIqdRateStream async* {
    yield _latestUsdToIqd;
    yield* _usdToIqdController.stream;
  }

  Stream<Map<String, double>> get commoditiesStream async* {
    yield _latestCommodities;
    yield* _commoditiesController.stream;
  }

  /// Kicks off an immediate fetch, then repeats every 60 seconds.
  void start() {
    _fetchAll();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchStocks(),
      _fetchConfig(),
    ]);
  }

  Future<void> _fetchStocks() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/stocks.json?ts=${DateTime.now().millisecondsSinceEpoch}'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final stocksJson = (data['stocks'] as List<dynamic>? ?? []);
      _latestStocks = stocksJson
          .map((e) => Stock.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _stocksController.add(_latestStocks);

      final lastUpdatedStr = data['lastUpdated']?.toString();
      _latestUpdated = lastUpdatedStr != null ? DateTime.tryParse(lastUpdatedStr) : null;
      _lastUpdatedController.add(_latestUpdated);
    } catch (e) {
      // Network hiccup or GitHub Pages cache miss - keep showing the last
      // good data and try again on the next 60s tick.
      // ignore: avoid_print
      print('DataService: failed to fetch stocks.json: $e');
    }
  }

  Future<void> _fetchConfig() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/config.json?ts=${DateTime.now().millisecondsSinceEpoch}'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      final currency = data['currency'] as Map<String, dynamic>? ?? {};
      _latestUsdToIqd = (currency['usdToIqd'] as num?)?.toDouble();
      _usdToIqdController.add(_latestUsdToIqd);

      final commodities = data['commodities'] as Map<String, dynamic>? ?? {};
      _latestCommodities = {
        'goldPerGramUsd': (commodities['goldPerGramUsd'] as num?)?.toDouble() ?? 0.0,
        'silverPerGramUsd': (commodities['silverPerGramUsd'] as num?)?.toDouble() ?? 0.0,
        'diamondPerCaratUsd': (commodities['diamondPerCaratUsd'] as num?)?.toDouble() ?? 0.0,
      };
      _commoditiesController.add(_latestCommodities);
    } catch (e) {
      // ignore: avoid_print
      print('DataService: failed to fetch config.json: $e');
    }
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
    _stocksController.close();
    _lastUpdatedController.close();
    _usdToIqdController.close();
    _commoditiesController.close();
  }
}
