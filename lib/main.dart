import 'package:flutter/material.dart';
import 'pages/compare_universal.dart';

void main() {
  runApp(const BuyBetterApp());
}

class BuyBetterApp extends StatelessWidget {
  const BuyBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0A84FF), // azul
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          elevation: 2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuyBetter',
      theme: theme,
      home: const HomeScreen(),
      routes: {
        '/compare': (_) => const CompareUniversalPage(),
        // '/scan': (_) => const ScanPage(), // (próxima etapa)
        // '/map':  (_) => const MapPage(),  // (próxima etapa)
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('BuyBetter', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Comparador inteligente e colaborativo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Botões grandes
            _BigActionButton(
              icon: Icons.balance_rounded,
              title: 'Comparar Itens',
              subtitle: 'Preço por unidade (ml, L, g, kg, un, m...)',
              onTap: () => Navigator.pushNamed(context, '/compare'),
            ),
            const SizedBox(height: 16),

            _BigActionButton(
              icon: Icons.camera_alt_rounded,
              title: 'Usar Câmera (QR/Produto)',
              subtitle: 'Leia QR/Código de barras ou foto do rótulo',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scanner virá na próxima etapa 👍')),
                );
                // Navigator.pushNamed(context, '/scan');
              },
            ),

            const Spacer(),

            // Rodapé
            Center(
              child: Text(
                'v1 • layout base • vamos evoluir o design',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.primary.withOpacity(.12),
                ),
                child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}