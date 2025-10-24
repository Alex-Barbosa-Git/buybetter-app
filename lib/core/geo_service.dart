// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// === Páginas da sua app (já criadas por você) ===
import 'pages/compare_universal.dart';
import 'pages/menu_qr_import.dart';

// === Serviço de geolocalização (OSM / Nominatim) ===
import 'core/geoservice.dart';

// ------------------------------------------------
// Configuração do app: .env + Supabase
// ------------------------------------------------
class AppConfig {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Carrega .env na raiz do projeto
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_KEY'];

    if (url == null || url.isEmpty || key == null || key.isEmpty) {
      debugPrint(
        "[AppConfig] Faltam variáveis no .env. "
        "Verifique SUPABASE_URL e SUPABASE_KEY.",
      );
    } else {
      await Supabase.initialize(url: url, anonKey: key);
    }
  }

  static SupabaseClient get supabase => Supabase.instance.client;
}

Future<void> main() async {
  await AppConfig.init();
  runApp(const BuyBetterApp());
}

// ------------------------------------------------
// App
// ------------------------------------------------
class BuyBetterApp extends StatelessWidget {
  const BuyBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
  elevation: 3,
  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuyBetter',
      theme: theme,
      home: const HomeScreen(),
      routes: {
        '/compare': (_) => const CompareUniversalPage(),
        '/scan': (_) => MenuQrImportPage(),
      },
    );
  }
}

// ------------------------------------------------
// Home (menu principal)
// ------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BuyBetter'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.layers_rounded, size: 44, color: cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo ao BuyBetter',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Compare preços, use QR e confirme locais via OSM.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Botões principais
                _MenuButton(
                  icon: Icons.calculate_rounded,
                  label: 'Comparar por unidade',
                  onTap: () => Navigator.pushNamed(context, '/compare'),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Usar câmera / QR (beta)',
                  onTap: () => Navigator.pushNamed(context, '/scan'),
                ),
                const SizedBox(height: 12),

                // ✅ Botão novo — Confirmar Local (OSM)
                _MenuButton(
                  icon: Icons.place_rounded,
                  label: 'Confirmar local (OSM)',
                  onTap: () async {
                    try {
                      final place = await GeoService.confirmHere(context);
                      if (place == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Local confirmado: ${place.name}')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),
                Text(
                  'v1.0.0 • Flutter • Supabase',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: cs.onPrimary),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label),
        ),
      ),
    );
  }
}