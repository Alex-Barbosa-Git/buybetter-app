// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

// Páginas
import 'pages/compare_universal.dart';
import 'pages/menu_qr_import.dart';
import 'pages/map_page.dart';

// Fundo com partículas
import 'widgets/particle_background.dart';

// ------------------------------------------------
class AppConfig {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_KEY'];
    if (url == null || key == null || url.isEmpty || key.isEmpty) {
      debugPrint("[AppConfig] ⚠️ Verifique SUPABASE_URL/SUPABASE_KEY no .env");
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
class BuyBetterApp extends StatelessWidget {
  const BuyBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BuyBetter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shadowColor: Colors.blueAccent.withOpacity(0.4), // ✅ corrigido
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/compare': (_) => const CompareUniversalPage(),
        '/scan': (_) => MenuQrImportPage(),
        '/map': (_) => const MapPage(),
      },
    );
  }
}

// ------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar transparente com ícone do mapa
      appBar: AppBar(
        title: const Text('BuyBetter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Mapa',
            icon: const Icon(Icons.map_rounded),
            onPressed: () => Navigator.pushNamed(context, '/map'),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Degradê animado
          AnimatedBuilder(
            animation: _ctl,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        Colors.blue.shade900,
                        Colors.deepPurple.shade700,
                        math.sin(_ctl.value * math.pi),
                      )!,
                      Color.lerp(
                        Colors.blue.shade500,
                        Colors.purpleAccent.shade200,
                        math.cos(_ctl.value * math.pi),
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),
          // 2) Partículas animadas
          const ParticleBackground(
            count: 70,
            maxSize: 3.6,
            speed: 0.28,
          ),
          // 3) Conteúdo central
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone do app (efeito glass)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Bem-vindo ao BuyBetter',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Compare qualquer produto por unidade, capture via QR e visualize preços no mapa colaborativo.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    _MenuButton(
                      icon: Icons.calculate_rounded,
                      label: 'Comparar por unidade',
                      onTap: () => Navigator.pushNamed(context, '/compare'),
                    ),
                    const SizedBox(height: 14),
                    _MenuButton(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Usar câmera / QR (beta)',
                      onTap: () => Navigator.pushNamed(context, '/scan'),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'v1.0.0 • Flutter • Supabase',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label),
        ),
      ),
    );
  }
}