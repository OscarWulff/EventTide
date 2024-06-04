import 'package:flutter/material.dart';
import 'pages/swipe.dart'; // Ensure you have the correct path to your swipe.dart file

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder Cards Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SwipeFeedPage(),
    );
  }
}

class SwipeFeedPage extends StatefulWidget {
  const SwipeFeedPage({super.key});

  @override
  _SwipeFeedPageState createState() => _SwipeFeedPageState();
}

class _SwipeFeedPageState extends State<SwipeFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinder Cards Demo11'),
      ),
      body: Center(
        child: TinderSwapCard(
          cardBuilder: (BuildContext context, int index) {
            return Card(
              child: Center(
                child: Text(
                  'Card $index',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
          totalNum: 6,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }
}
