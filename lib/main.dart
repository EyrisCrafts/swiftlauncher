import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swiftlauncher/Providers/AppThemeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerChangeProvider.dart';
import 'package:swiftlauncher/Providers/DrawerHeightProvider.dart';
import 'package:swiftlauncher/Providers/ProviderHiddenApps.dart';
import 'package:swiftlauncher/screens/MainScreen.dart';

import 'Providers/ProviderDrawerApps.dart';
import 'Providers/ProviderIconPack.dart';
import 'Providers/ProviderPageViewIssue.dart';
import 'Providers/ProviderSettings.dart';
// import 'package:launcher_assist/launcher_assist.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeDilation = 0.3;
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // List<String> hiddenApps = prefs.getStringList('hiddenapps') ?? List();
  // log("HIDDEN APPS ARE ${hiddenApps.length}");
  runApp(MyApp(
      // hiddenapps: hiddenApps,
      ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // final List<String> hiddenapps;

  // const MyApp({Key key, @required this.hiddenapps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppThemeProvider()),
        ChangeNotifierProvider(create: (context) => DrawerHeightProvider()),
        ChangeNotifierProvider(create: (context) => DrawerChangeProvider()),
        ChangeNotifierProvider(create: (context) => ProviderSettings()),
        ChangeNotifierProvider(create: (context) => ProviderPageViewIssue()),
        ChangeNotifierProvider(
          create: (context) => ProviderHiddenApps(hiddenApps),
        ),
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
