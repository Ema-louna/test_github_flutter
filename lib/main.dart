import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('carsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> get carList => ['Dodge Ram', 'Toyota Corolla', 'Honda CRV', 'GMC Sierra'];
  final TextEditingController _textController = TextEditingController();
  final List<String> _cars = [];
  late final Box<String> carsBox = Hive.box<String>('carsBox');
  List<String> get _car => carsBox.values.toList();



  void _addCar(){
    setState(() {
      if(_textController.text.isNotEmpty){
        carsBox.add(_textController.text);
        _textController.clear();
        setState(() {

        });//refresh the UI
      }
    });
  }

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Padding( padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter car name/model',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(onPressed: _addCar,
                child: const Text('Add Car'),
            ),



        Expanded(child: ValueListenableBuilder(valueListenable: carsBox.listenable(),
            builder: (context, Box<String> box, _){
          final cars = box.values.toList();

        return ListView.builder(
          itemCount: cars.length,
            itemBuilder: (context, index){
          return ListTile(
            title: Text(cars[index]),
            onTap: (){
              //placeholder for showing the details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${cars[index]}')),
              );
                  },
              );
              },
              );
        }
              ),
              ),
              ],

    ),
    ),





      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
