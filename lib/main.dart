import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_qr/screens/home_18.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:provider/provider.dart';

const appTitle = 'Menu QR App';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DishProvider()),
      ChangeNotifierProvider(create: (_) => BillProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 178, 214)),
          useMaterial3: true),
      // home: const ResponsiveLayout(
      //     mobileBody: Scaffold(), desktopBody: Scaffold())
      home: const Home18(),
    );
  }
}
