import 'package:flutter/material.dart';
import 'pages/compare_universal.dart';
import 'pages/menu_qr_import.dart';

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
      debugShowCheckedModeBanner: false,
      home: const PlaceholderHome(),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BuyBetter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bem-vindo ao BuyBetter — georreferenciado e colaborativo!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CompareUniversalPage()),
                );
              },
              child: const Text('Comparar por unidade'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuQrImportPage()),
                );
              },
              child: const Text('Ler cardápio (QR)'),
            ),
          ],
        ),
      ),
    );
  }
}