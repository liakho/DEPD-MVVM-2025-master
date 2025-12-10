import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:depd_mvvm_2025/shared/style.dart';
import 'package:depd_mvvm_2025/view/pages/pages.dart';
import 'package:depd_mvvm_2025/viewmodel/home_viewmodel.dart';
import 'package:depd_mvvm_2025/viewmodel/international_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => InternationalViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter x RajaOngkir API',
        theme: ThemeData(
          primaryColor: Style.blue800,
          scaffoldBackgroundColor: Style.grey50,
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    InternationalPage(),
    HelloPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Domestic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'International',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Hello',
          ),
        ],
      ),
    );
  }
}
