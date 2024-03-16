import 'dart:math';

import 'package:flutter/material.dart';
import 'package:protos/protos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Grpc Example'),
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
  late ClientChannel _channel;
  late TodoServiceClient _stub;
  Stream<Todo>? _todoStream;
  Todo? todo;
  @override
  void initState() {
    super.initState();
    _channel = ClientChannel(
      'localhost',
      port: 8080,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub = TodoServiceClient(_channel);
    final id = Random().nextInt(100);
    _todoStream = _stub.getTodoStream(GetTodoByIdRequest(id: id));
  }

  void _getTodo() async {
    final id = Random().nextInt(100);
    final todo = await _stub.getTodo(GetTodoByIdRequest(id: id));
    setState(() {
      this.todo = todo;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _todoStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(snapshot.data!.id.toString()),
                      Text(snapshot.data!.message),
                      Text(snapshot.data!.completed.toString()),
                    ],
                  );
                }

                return const Text('GET YOUR TODO');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getTodo,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
