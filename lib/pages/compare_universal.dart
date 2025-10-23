import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Dim { volume, mass, length, area, unit }

class UnitDef {
  final String symbol;
  final double toBase; // fator p/ unidade base da dimensão
  const UnitDef(this.symbol, this.toBase);
}

// Bases padrão:
// volume: L      mass: kg       length: m       area: m²       unit: un
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
    UnitDef('cm²', 0.0001), UnitDef('m²', 1),
    UnitDef('ha', 10000), UnitDef('km²', 1e6),
  ],
  Dim.unit: [
    UnitDef('un', 1), UnitDef('dz', 12), UnitDef('pacote(variável)', 1),
  ],
};

class Item {
  Item({
    required this.label,
    required this.price,
    required this.qty,
    required this.dim,
    required this.unit,
    this.packCount = 1,
  });

  String label;
  double price;
  double qty;       // quantidade na unidade escolhida (ex.: 350 mL, 500 g)
  Dim dim;
  UnitDef unit;
  int packCount;    // para kits/packs (ex.: 6 long necks)

  double get amountInBase {
    // converte quantidade * unidades por pack → base da dimensão
    return (qty * unit.toBase) * (packCount <= 0 ? 1 : packCount);
  }

  String get baseSymbol {
    switch (dim) {
      case Dim.volume: return 'L';
      case Dim.mass: return 'kg';
      case Dim.length: return 'm';
      case Dim.area: return 'm²';
      case Dim.unit: return 'un';
    }
  }

  double get pricePerBase {
    final baseAmount = amountInBase;
    return price / (baseAmount == 0 ? 1 : baseAmount);
  }
}

class CompareUniversalPage extends StatefulWidget {
  const CompareUniversalPage({super.key});
  @override
  State<CompareUniversalPage> createState() => _CompareUniversalPageState();
}

class _CompareUniversalPageState extends State<CompareUniversalPage> {
  final _money = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final _items = <Item>[];

  // input state
  Dim _dim = Dim.volume;
  UnitDef _unit = unitsByDim[Dim.volume]!.first;
  final _label = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _pack = TextEditingController(text: '1');

  void _onDimChanged(Dim d) {
    setState(() {
      _dim = d;
      _unit = unitsByDim[d]!.first;
    });
  }

  void _add() {
    final label = _label.text.trim();
    final price = double.tryParse(_price.text.replaceAll(',', '.')) ?? 0;
    final qty = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 0;
    final pack = int.tryParse(_pack.text) ?? 1;
    if (label.isEmpty || price <= 0 || qty <= 0 || pack <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, preço, quantidade e pack.')),
      );
      return;
    }
    setState(() {
      _items.add(Item(
        label: label, price: price, qty: qty, dim: _dim, unit: _unit, packCount: pack,
      ));
      _label.clear(); _price.clear(); _qty.clear(); _pack.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._items]..sort((a, b) => a.pricePerBase.compareTo(b.pricePerBase));
    return Scaffold(
      appBar: AppBar(title: const Text('Comparador universal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            const Text('Dimensão: '),
            DropdownButton<Dim>(
              value: _dim, onChanged: (v) => _onDimChanged(v!),
              items: const [
                DropdownMenuItem(value: Dim.volume, child: Text('Volume (R$/L)')),
                DropdownMenuItem(value: Dim.mass, child: Text('Massa (R$/kg)')),
                DropdownMenuItem(value: Dim.length, child: Text('Comprimento (R$/m)')),
                DropdownMenuItem(value: Dim.area, child: Text('Área (R$/m²)')),
                DropdownMenuItem(value: Dim.unit, child: Text('Unidade (R$/un)')),
              ],
            ),
            const SizedBox(width: 12),
            const Text('Unidade: '),
            DropdownButton<UnitDef>(
              value: _unit,
              onChanged: (u) => setState(() => _unit = u!),
              items: unitsByDim[_dim]!
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.symbol))).toList(),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _label, decoration: const InputDecoration(labelText: 'Nome do item'),),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(
              controller: _price, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preço (R$)'),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _qty, keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade (${_unit.symbol})'),
            )),
            const SizedBox(width: 8),
            SizedBox(width: 90, child: TextField(
              controller: _pack, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pack'),
            )),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Adicionar')),
          ),
          const Divider(),
          Expanded(
            child: sorted.isEmpty
              ? const Center(child: Text('Adicione itens para comparar.'))
              : ListView.builder(
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final it = sorted[i];
                    final best = i == 0;
                    return ListTile(
                      leading: best ? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.shopping_cart),
                      title: Text(it.label),
                      subtitle: Text('Preço: ${_money.format(it.price)} · Qtd: ${it.qty} ${it.unit.symbol} · Pack: ${it.packCount}'),
                      trailing: Text('R\$/${it.baseSymbol}\n${_money.format(it.pricePerBase)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: best ? FontWeight.bold : FontWeight.normal, color: best ? Colors.green[700] : null),
                      ),
                    );
                  }),
          ),
        ]),
      ),
    );
  }
}