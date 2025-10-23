import 'package:flutter/material.dart';

class MenuQrImportPage extends StatelessWidget {
  const MenuQrImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler cardápio (QR)')),
      body: const Center(
        child: Text('Em breve: scanner de QR e OCR do cardápio'),
      ),
    );
  }
}