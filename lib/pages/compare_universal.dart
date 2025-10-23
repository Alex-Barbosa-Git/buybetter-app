import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Dim { volume, mass, length, area, unit }

class UnitDef {
  final String symbol;
  final double toBase; // fator p/ unidade base da dimensão
  const UnitDef(this.symbol, this.toBase);
}

// Bases: volume=L, massa=kg, comprimento=m, área=m², unit=un
const unitsByDim = <Dim, List<UnitDef>>{
  Dim.volume: [
    UnitDef('mL', 0.001), UnitDef('L', 1), UnitDef('gal', 3.78541),
  ],
  Dim.mass: [
    UnitDef('g', 0.001), UnitDef('kg', 1), UnitDef('lb', 0.453592),
  ],
  Dim.length: [
    UnitDef('cm', 0.01), UnitDef('m', 1), UnitDef('km', 1000),
  ],
  Dim.area: [
    UnitDef('cm²', 0.0001), UnitDef('m²', 1), UnitDef('ha', 10000),
  ],
  Dim.unit: [
    UnitDef('un', 1),
  ],
};

class Item {
  final String label;
  final double price;
  final double qty;
  final UnitDef unit;
  const Item({required this.label, required this.price, required this.qty, required this.unit});
  double get baseAmount => qty * unit.toBase;
  double get pricePerBase => price / baseAmount;
}

class CompareUniversalPage extends StatefulWidget {
  const CompareUniversalPage({super.key});
  @override
  State<CompareUniversalPage> createState() => _CompareUniversalPageState();
}

class _CompareUniversalPageState extends State<CompareUniversalPage> {
  Dim dim = Dim.volume;
  final _items = <Item>[];
  final _fmt = NumberFormat.simpleCurrency(locale: 'pt_BR');

  UnitDef get defaultUnit => unitsByDim[dim]!.first;

  void _addItem() {
    setState(() {
      _items.add(
        Item(label: 'Item ${_items.length + 1}', price: 5, qty: 350, unit: defaultUnit),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = unitsByDim[dim]!;
    final sorted = [..._items]..sort((a, b) => a.pricePerBase.compareTo(b.pricePerBase));

    return Scaffold(
      appBar: AppBar(title: const Text('Comparador universal')),
      floatingActionButton: FloatingActionButton(onPressed: _addItem, child: const Icon(Icons.add)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<Dim>(
              value: dim,
              items: Dim.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
              onChanged: (d) => setState(() => dim = d!),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final it = sorted[i];
                  return ListTile(
                    title: Text(it.label),
                    subtitle: Text(
                      '${_fmt.format(it.price)} — ${it.qty} ${it.unit.symbol}  '
                      '(${it.pricePerBase.toStringAsFixed(4)} por base)',
                    ),
                  );
                },
              ),
            ),
            if (_items.isEmpty)
              const Text('Toque em + para adicionar itens e comparar'),
          ],
        ),
      ),
    );
  }
}