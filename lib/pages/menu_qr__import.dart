import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class MenuQrImportPage extends StatefulWidget {
  const MenuQrImportPage({super.key});
  @override
  State<MenuQrImportPage> createState() => _MenuQrImportPageState();
}

class _MenuQrImportPageState extends State<MenuQrImportPage> {
  String? _scannedUrl;
  bool _fetching = false;
  List<Map<String, dynamic>> _items = [];
  Position? _pos;

  Future<void> _ensureLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (!enabled || perm == LocationPermission.deniedForever) return;
    _pos = await Geolocator.getCurrentPosition();
  }

  Future<void> _onDetect(BarcodeCapture cap) async {
    if (_scannedUrl != null) return; // evita múltiplas leituras
    final raw = cap.barcodes.first.rawValue;
    if (raw == null) return;
    // Aceita apenas http/https
    if (!raw.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR não é uma URL.')));
      return;
    }
    setState(() => _scannedUrl = raw);
    await _fetchAndParse(raw);
  }

  Future<void> _fetchAndParse(String url) async {
    setState(() { _fetching = true; _items = []; });
    await _ensureLocation();

    try {
      final resp = await http.get(Uri.parse(url));
      final text = utf8.decode(resp.bodyBytes, allowMalformed: true);
      final doc = html.parse(text);

      // 1) tenta extrair itens em elementos comuns
      final candidates = <String>[];
      for (final e in doc.querySelectorAll('li, p, span, td, div')) {
        final t = e.text.trim();
        if (t.isNotEmpty) candidates.add(t);
      }

      // 2) acha padrões de preço (R$ 12,34 / 12,34 / 12.34)
      final regexPrice = RegExp(r'(R\$\s*)?(\d{1,3}(\.\d{3})*|\d+)[,\.]\d{2}');
      final parsed = <Map<String, dynamic>>[];
      for (final line in candidates.take(400)) { // limita pra não explodir
        final m = regexPrice.firstMatch(line);
        if (m != null) {
          final priceStr = m.group(0)!;
          final name = line.replaceFirst(priceStr, '').trim();
          final normalized = priceStr.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.');
          final price = double.tryParse(normalized) ?? 0;
          if (name.isNotEmpty && price > 0) {
            parsed.add({'name': name, 'price': price});
          }
        }
      }

      setState(() { _items = parsed; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao baixar/parsing: $e')));
    } finally {
      setState(() => _fetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');

    if (_scannedUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ler QR do cardápio')),
        body: MobileScanner(
          onDetect: _onDetect,
          controller: MobileScannerController(formats: [BarcodeFormat.qrCode]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado do cardápio')),
      body: _fetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('URL: $_scannedUrl'),
                  const SizedBox(height: 6),
                  if (_pos != null)
                    Text('Local: lat ${_pos!.latitude.toStringAsFixed(5)}, '
                         'lng ${_pos!.longitude.toStringAsFixed(5)}'),
                  const Divider(),
                  Expanded(
                    child: _items.isEmpty
                        ? const Center(child: Text('Nenhum item reconhecido.'))
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (_, i) {
                              final it = _items[i];
                              return ListTile(
                                title: Text(it['name']),
                                trailing: Text(money.format(it['price'])),
                              );
                            }),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Aqui você salvaria em banco (Supabase) com:
                      // url, items, latitude, longitude, timestamp, user_id.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('(MVP) Dados prontos para salvar.')),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar (MVP)'),
                  ),
                ],
              ),
            ),
    );
  }
}