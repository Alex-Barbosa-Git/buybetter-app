import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MenuQrImportPage extends StatefulWidget {
  const MenuQrImportPage({super.key});

  @override
  State<MenuQrImportPage> createState() => _MenuQrImportPageState();
}

class _MenuQrImportPageState extends State<MenuQrImportPage> {
  String? lastText;
  bool scanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar cardápio (QR)')),
      body: Column(
        children: [
          Expanded(
            child: scanning
                ? MobileScanner(
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull;
                      final value = barcode?.rawValue;
                      if (value == null) return;
                      setState(() {
                        scanning = false;
                        lastText = value;
                      });
                      // TODO: se for URL, baixar/parsear o cardápio aqui
                    },
                  )
                : const Center(child: Text('Leitura concluída')),
          ),
          if (lastText != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText('Conteúdo detectado:\n$lastText'),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() {
              scanning = true;
              lastText = null;
            }),
            child: const Text('Ler novamente'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}