import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:swiftlauncher/Providers/AppThemeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerChangeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerHeightProvider.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

import 'Providers/ProviderDrawerApps.dart';
import 'Providers/ProviderIconPack.dart';
import 'Providers/ProviderSettings.dart';
// import 'package:launcher_assist/launcher_assist.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppThemeProvider()),
        ChangeNotifierProvider(create: (context) => DrawerHeightProvider()),
        ChangeNotifierProvider(create: (context) => DrawerChangeProvider()),
        ChangeNotifierProvider(create: (context) => ProviderSettings()),
        ChangeNotifierProvider(
            create: (context) => ProviderIconPack(Map(), "")),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Swift Launcher',
          darkTheme: ThemeData(
            primarySwatch: Colors.grey,
            primaryColor: Colors.black,
            brightness: Brightness.dark,
            backgroundColor: const Color(0xFF212121),
            accentIconTheme: IconThemeData(color: Colors.black),
            dividerColor: Colors.black12,
          ),
          themeMode: Provider.of<ProviderSettings>(context).getIsDarkTheme
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MainScreen(),
        ),
      ),
    );
  }
}
