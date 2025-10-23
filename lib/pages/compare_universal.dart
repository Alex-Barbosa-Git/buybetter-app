import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum UnitCategory { volume, mass, length, unit }

class _ItemRow {
  String label;
  double? price;
  double? qty;
  String unit; // ex: ml, L, g, kg, m, un

  _ItemRow({this.label = '', this.price, this.qty, this.unit = 'un'});
}

class CompareUniversalPage extends StatefulWidget {
  const CompareUniversalPage({super.key});

  @override
  State<CompareUniversalPage> createState() => _CompareUniversalPageState();
}

class _CompareUniversalPageState extends State<CompareUniversalPage> {
  final List<_ItemRow> items = [ _ItemRow() ];
  final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  // Conversão para unidade base por categoria
  // volume -> base: L ; mass -> base: kg ; length -> base: m ; unit -> base: un
  static const Map<String, (UnitCategory cat, double toBase)> units = {
    // volume
    'ml': (UnitCategory.volume, 0.001),
    'l' : (UnitCategory.volume, 1.0),

    // mass
    'g' : (UnitCategory.mass, 0.001),
    'kg': (UnitCategory.mass, 1.0),

    // length
    'cm': (UnitCategory.length, 0.01),
    'm' : (UnitCategory.length, 1.0),

    // unit
    'un': (UnitCategory.unit, 1.0),
  };

  UnitCategory? _categoryOfList() {
    // categoria fica definida pela 1ª unidade válida encontrada
    for (final it in items) {
      final u = it.unit.trim().toLowerCase();
      if (units.containsKey(u)) return units[u]!.$1;
    }
    return null;
  }

  // Normaliza p/ base (L, kg, m, un) e retorna preço por base
  double? _pricePerBase(_ItemRow it) {
    if (it.price == null || it.qty == null) return null;
    final u = it.unit.trim().toLowerCase();
    final def = units[u];
    if (def == null) return null;
    final toBase = def.$2;
    final baseQty = it.qty! * toBase;
    if (baseQty <= 0) return null;
    return it.price! / baseQty;
  }

  String _baseSuffix(UnitCategory cat) {
    switch (cat) {
      case UnitCategory.volume: return 'L';
      case UnitCategory.mass:   return 'kg';
      case UnitCategory.length: return 'm';
      case UnitCategory.unit:   return 'un';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = _categoryOfList();
    // calcula e ordena (sem mexer na ordem visual original)
    final computed = <int, double?>{
      for (int i = 0; i < items.length; i++) i : _pricePerBase(items[i])
    };

    // encontra o menor preço por base (para destacar)
    double? minVal;
    for (final v in computed.values) {
      if (v != null) {
        minVal = (minVal == null) ? v : (v < minVal! ? v : minVal);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Comparar Itens')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => items.add(_ItemRow())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar item'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _hintCard(context),
          const SizedBox(height: 12),

          // Tabela de linhas
          for (int i = 0; i < items.length; i++) _rowCard(context, i, cat, computed[i], minVal),

          const SizedBox(height: 12),
          if (cat != null)
            Text(
              'Unidade base desta comparação: ${_baseSuffix(cat)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _hintCard(BuildContext ctx) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Preencha NOME, PREÇO, QUANTIDADE e UNIDADE (ex: ml, L, g, kg, m, un). '
              'O app calcula o preço por L / kg / m / unidade e destaca o mais barato.',
            ),
          ),
        ],
      ),
    ),
  );

  Widget _rowCard(BuildContext ctx, int idx, UnitCategory? cat, double? ppu, double? minVal) {
    final it = items[idx];
    final isBest = (ppu != null && minVal != null && (ppu - minVal!).abs() < 1e-9);

    return Card(
      color: isBest ? Theme.of(ctx).colorScheme.primary.withOpacity(.06) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Nome do item'),
                    onChanged: (v) => it.label = v,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Remover',
                  onPressed: () => setState(() => items.removeAt(idx)),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(prefixText: 'R\$ ', labelText: 'Preço'),
                    onChanged: (v) => it.price = double.tryParse(v.replaceAll(',', '.')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    onChanged: (v) => it.qty = double.tryParse(v.replaceAll(',', '.')),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    value: units.containsKey(it.unit.toLowerCase()) ? it.unit.toLowerCase() : 'un',
                    items: const [
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'l',  child: Text('L')),
                      DropdownMenuItem(value: 'g',  child: Text('g')),
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'cm', child: Text('cm')),
                      DropdownMenuItem(value: 'm',  child: Text('m')),
                      DropdownMenuItem(value: 'un', child: Text('un')),
                    ],
                    onChanged: (v) => setState(() => it.unit = v ?? 'un'),
                    decoration: const InputDecoration(labelText: 'Unidade'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (ppu == null)
                  ? '—'
                  : 'Preço por ${cat == null ? "base" : _baseSuffix(cat)}: ${currency.format(ppu)}',
                style: TextStyle(
                  fontWeight: isBest ? FontWeight.w800 : FontWeight.w500,
                  color: isBest ? Theme.of(ctx).colorScheme.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}