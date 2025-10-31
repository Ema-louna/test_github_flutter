import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'car_detail_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_github_flutter/l10n/app_localizations.dart';


/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('carsBox');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  Locale? _locale;
  void _setLocale(Locale locale){
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cars for Sale page',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(
        title: 'Cars for Sale page',

        carsBox: Hive.box('carsBox'),
        onLocaleChange: _setLocale,
      ),
    );
  }
}
*/
class CarsHomePage extends StatefulWidget {
  final String title;
  final Box carsBox;
  final Function(Locale) onLocaleChange;

  const CarsHomePage({super.key, required this.title, required this.carsBox, required this.onLocaleChange });

  @override
  State<CarsHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CarsHomePage> {
  final TextEditingController _textController = TextEditingController();
  int? _selectedIndex;
  Box get carsBox => Hive.box('carsBox');
final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();




  @override
void initState() {
    super.initState();
    _loadSavedText();
    _textController.addListener(() {
      _saveTextSecurely(_textController.text);
    });
  }

  // Load saved text from secure storage
  Future<void> _loadSavedText() async {
    String? savedText = await _secureStorage.read(key: 'lastCarText');
    if (savedText != null) {
      setState(() {
        _textController.text = savedText;
      });
    }
  }

  //Save typed text securely
  Future<void> _saveTextSecurely(String text) async {
    await _secureStorage.write(key: 'lastCarText', value: text);
  }



  void _addCar() {
    if (_textController.text.isNotEmpty) {
      final newCar = {
        'name': _textController.text,
        'model': 'Unknown',
        'year': '2025',
        'color': 'N/A',
        'description': 'No details added yet',
      };

      carsBox.add(newCar); // store as a new car in Hive
    _secureStorage.delete(key:'lastCarText');

      setState(() {});
      // SHOW SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Car added: ${newCar['name']}'),
              duration: Duration(seconds: 3),
          ),
      );
    }
  }

  Map _getCar(dynamic carRaw) {
    if (carRaw is Map) return carRaw;
    // convert old Strings or any other type to Map
    return {
      'name': carRaw.toString(),
      'model': 'Unknown',
      'year': '2025',
      'color': 'N/A',
      'description': 'No details added yet',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
      icon: Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.instructionsTitle),
              content: Text(
                AppLocalizations.of(context)!.instructionsText),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok),
            )
          ],
            ),
            );
                },
            ),

        // Language en/fr button
        PopupMenuButton<Locale>(
          icon: Icon(Icons.language),
          onSelected: (Locale locale) {
            widget.onLocaleChange(locale);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: Locale('en'),
              child: Text('English'),
            ),
            PopupMenuItem(
              value: Locale('fr'),
              child: Text('Français'),
            ),
          ],
        ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterCarName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCar,
              child: Text(AppLocalizations.of(context)!.addCar),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ValueListenableBuilder(
                      valueListenable: carsBox.listenable(),
                      builder: (context, Box box, _) {
                        final cars = box.values.toList();
                        return ListView.builder(
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            final car = _getCar(cars[index]);
                            return ListTile(
                              title: Text(car['name']),
                              selected: _selectedIndex == index,
                              onTap: () {
                                final car = _getCar(widget.carsBox.getAt(index));
                                final isWideScreen = MediaQuery.of(context).size.width >= 600;

                                if (isWideScreen) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected car: ${car['name']}'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CarDetailPage(
                                        index: index,
                                        carData: car,
                                      ),
                                    ),
                                  ).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Selected car: ${car['name']}'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    setState(() {});
                                  });
                                }

                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Right side: detail panel (only on wide screens)
                  if (_selectedIndex != null && MediaQuery.of(context).size.width >= 600)
                    Expanded(
                      child: CarDetailPage(
                        key: ValueKey(_selectedIndex), // use index key only
                        index: _selectedIndex!,
                        carData: _getCar(widget.carsBox.getAt(_selectedIndex!)),
                        fullScreen: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
