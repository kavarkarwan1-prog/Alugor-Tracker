import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/data_service.dart';
import 'services/favorites_service.dart';
import 'screens/stock_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/currency_converter_screen.dart';
import 'screens/commodities_screen.dart';

// Point this at your published GitHub Pages site, no trailing slash.
// e.g. if your repo is github.com/yourname/isx-tracker with Pages serving
// the /docs folder, this is usually https://yourname.github.io/isx-tracker
const String kDataFeedBaseUrl = 'https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final favoritesService = FavoritesService();
  await favoritesService.load();

  final dataService = DataService(baseUrl: kDataFeedBaseUrl);
  dataService.start();

  runApp(IraqiBorsaTrackerApp(
    favoritesService: favoritesService,
    dataService: dataService,
  ));
}

class IraqiBorsaTrackerApp extends StatelessWidget {
  final FavoritesService favoritesService;
  final DataService dataService;

  const IraqiBorsaTrackerApp({
    super.key,
    required this.favoritesService,
    required this.dataService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider.value(value: favoritesService),
        Provider<DataService>.value(value: dataService),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Iraqi Borsa Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const RootNav(),
          );
        },
      ),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    StockListScreen(),
    FavoritesScreen(),
    CalculatorScreen(),
    CurrencyConverterScreen(),
    CommoditiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Stocks'),
          NavigationDestination(icon: Icon(Icons.star_border_rounded), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Calculator'),
          NavigationDestination(icon: Icon(Icons.currency_exchange), label: 'Currency'),
          NavigationDestination(icon: Icon(Icons.diamond_outlined), label: 'Metals'),
        ],
      ),
    );
  }
}
