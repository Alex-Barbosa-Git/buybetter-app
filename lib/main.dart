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
      debugShowCheckedModeBanner: false,
      title: 'BuyBetter',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
      routes: {
        '/compare': (context) => const CompareUniversalPage(),
        '/menuqr': (context) => const MenuQrImportPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BuyBetter'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bem-vindo ao BuyBetter 👋\nEscolha uma função para começar:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Comparador Universal'),
                onPressed: () {
                  Navigator.pushNamed(context, '/compare');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Importar Cardápio via QR Code'),
                onPressed: () {
                  Navigator.pushNamed(context, '/menuqr');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}