import 'package:flutter/material.dart';
import 'package:ponglike/pong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PongPage(),
    );
  }
}

class PongPage extends StatefulWidget {
  const PongPage({super.key});

  @override
  State<PongPage> createState() => _PongPageState();
}

class _PongPageState extends State<PongPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pong!"),
      ),
      body: const Center(
        child: SizedBox(
          width: 400.0,
          height: 400.0,
          child: PongView(),
        ),
      ),
    );
  }
}
