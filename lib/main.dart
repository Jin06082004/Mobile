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
      home: const MyHomePage(title: 'Library Test Page'),
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
  String _testResult = 'Press a button or see initial test run results below.';

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  // Simulates running a single test
  String _runSingleTest(int testNumber) {
    // TODO: Replace with your library's actual test function
    return 'Test $testNumber executed successfully!';
  }

  void _runTest1() {
    setState(() {
      _testResult = _runSingleTest(1);
    });
  }

  void _runTest2() {
    setState(() {
      _testResult = _runSingleTest(2);
    });
  }

    void _runTest3() {
    setState(() {
      _testResult = _runSingleTest(3);
    });
  }

  void _runAllTests() {
    // TODO: Replace with your library's test functions
    String result1 = _runSingleTest(1);
    String result2 = _runSingleTest(2);
    String result3 = _runSingleTest(3);

    setState(() {
      _testResult = 'Automatic Run:\n$result1\n$result2\n$result3';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Test Result:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                _testResult,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _runTest1,
                child: const Text('Run Test 1'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _runTest2,
                child: const Text('Run Test 2'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _runTest3,
                child: const Text('Run Test 3'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
