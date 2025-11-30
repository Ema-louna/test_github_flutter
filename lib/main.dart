import 'package:flutter/material.dart';
import 'car_main.dart';
import 'customer_main.dart';
import 'boat_main.dart';

import 'app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],

      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!.translate;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("main_page_title")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: [
          // ⭐ Instructions button
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Instructions",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(tr("instructions") ?? "Instructions"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ${tr("i_add") ?? "Add a car from the main menu"}"),
                      Text("• ${tr("i_tap") ?? "Tap a car to edit or delete it"}"),
                      Text("• ${tr("i_wide") ?? "Wide screens show split view"}"),
                      Text("• ${tr("i_delete") ?? "You can delete an item anytime"}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🌐 Language button
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
            onPressed: () {
              final current = Localizations.localeOf(context).languageCode;

              if (current == 'en') {
                MyApp.setLocale(context, const Locale('fr'));
              } else {
                MyApp.setLocale(context, const Locale('en'));
              }
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarsMain()),
                );
              },
              child: Text(tr("cars")),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BoatMain()),
                );
              },
              child: Text(tr("boats")),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              child: Text(tr("purchases")),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerMain()),
                );
              },
              child: Text(tr("customers")),
            ),
          ],
        ),
      ),
    );
  }
}
