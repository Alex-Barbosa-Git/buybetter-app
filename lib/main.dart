import 'package:flutter/material.dart';

void main() {
  runApp(const BuyBetterApp());
}

class BuyBetterApp extends StatelessWidget {
  const BuyBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuyBetter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const PlaceholderHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BuyBetter')),
      body: const Center(
        child: Text('Bem-vindo ao BuyBetter — georreferenciado e colaborativo!'),
      ),
    );
  }
}
