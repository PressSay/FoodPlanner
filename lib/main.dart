import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_qr/screens/home_18.dart';
import 'package:menu_qr/services/providers/bill_provider.dart';
import 'package:menu_qr/services/providers/dish_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const appTitle = 'Food Planner';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;

  final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(0, 107, 8, 107), // Màu nâu nhạt
      brightness: Brightness.light, // Theme sáng
    ),
    useMaterial3: true,
  );

  final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0x00210021), // Màu nâu nhạt
      brightness: Brightness.dark, // Theme tối
    ),
    useMaterial3: true,
  );

  void changeToDark() {
    setState(() {
      themeMode = ThemeMode.dark;
    });
  }

  void changeToLight() {
    setState(() {
      themeMode = ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('vi'), // Vietnamese
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      // home: const ResponsiveLayout(
      //     mobileBody: Scaffold(), desktopBody: Scaffold())
      home: Home18(
          themeMode: themeMode,
          changeToDark: changeToDark,
          changeToLight: changeToLight),
    );
  }
}
