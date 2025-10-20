import 'package:flutter/material.dart';

void main() {
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


  void _addCar(){
    setState(() {
      if(_textController.text.isNotEmpty){
        _cars.add(_textController.text);
        _textController.clear();
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


        Expanded(child: ListView.builder(
          itemCount: carList.length,
            itemBuilder: (context, index){
          return ListTile(
            title: Text(carList[index]),
            onTap: (){
              //placeholder for showing the details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${carList[index]}')),

              );
            },
          );
        })
      ),],
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
