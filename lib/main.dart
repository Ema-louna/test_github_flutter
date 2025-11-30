import 'package:flutter/material.dart';
import 'car_main.dart';
import 'customer_main.dart';
import 'boat_main.dart';

import 'app_localizations.dart';                     // ← REQUIRED
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Allows any page to change the app language
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default English

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,                                       // ← important
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // ⭐ Localization setup
      localizationsDelegates: const [
        AppLocalizations.delegate,                           // ← YOUR delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],

      home: const MyHomePage(title: 'Main Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ⭐ AppBar with language-switch button
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
            onPressed: () {
              final current = Localizations.localeOf(context).languageCode;

              // Toggle EN ↔ FR
              if (current == 'en') {
                MyApp.setLocale(context, const Locale('fr'));
              } else {
                MyApp.setLocale(context, const Locale('en'));
              }
            },
          )
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
              child: const Text('Cars'),   // Will translate later
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BoatMain()),
                );
              },
              child: const Text('Boat'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {},
              child: const Text('Purchase'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerMain()),
                  );
                },
                child: const Text('Customer')
            ),
          ],
        ),
      ),
    );
  }
}
