// lib/widgets/particle_background.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({
    super.key,
    this.count = 60,
    this.maxSize = 3.2,
    this.speed = 0.25,
    this.color,
  });

  final int count;        // número de partículas
  final double maxSize;   // tamanho máximo do ponto
  final double speed;     // velocidade base (0.15~0.4)
  final Color? color;     // cor base (default: branco)

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  final _rand = math.Random();
  late List<_P> _ps;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _ps = List.generate(widget.count, (_) => _P.random(_rand));
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _ps,
            t: _ctl.value,
            color: color,
            maxSize: widget.maxSize,
            speed: widget.speed,
          ),
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _P {
  // posição base (0..1 relativo ao canvas)
  final double x0, y0;
  // direção/velocidade pseudo-aleatória
  final double dx, dy, amp;
  // tamanho base
  final double r;

  _P(this.x0, this.y0, this.dx, this.dy, this.amp, this.r);

  factory _P.random(math.Random rand) {
    final x0 = rand.nextDouble();
    final y0 = rand.nextDouble();
    // direção leve
    final ang = rand.nextDouble() * 2 * math.pi;
    final dx = math.cos(ang);
    final dy = math.sin(ang);
    final amp = 0.004 + rand.nextDouble() * 0.016; // amplitude do vai-e-vem
    final r = 0.6 + rand.nextDouble() * 1.0;       // raio base (em px relativo)
    return _P(x0, y0, dx, dy, amp, r);
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_P> particles;
  final double t; // 0..1
  final Color color;
  final double maxSize;
  final double speed;

  _ParticlesPainter({
    required this.particles,
    required this.t,
    required this.color,
    required this.maxSize,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // glow (desfoque) e ponto central
    final glow = Paint()
      ..color = color.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final dot = Paint()
      ..color = color.withOpacity(0.85)
      ..isAntiAlias = true;

    for (final p in particles) {
      // movimento suave (seno/cosseno) + drift em t
      final tt = t * speed * 2 * math.pi;
      final x = (p.x0 + p.dx * p.amp * math.sin(tt + p.x0 * 10)).clamp(0.0, 1.0);
      final y = (p.y0 + p.dy * p.amp * math.cos(tt + p.y0 * 10)).clamp(0.0, 1.0);

      // tamanho respira levemente
      final breathe = 0.5 + 0.5 * math.sin(tt * 0.8 + p.x0 * 8);
      final r = (p.r + breathe) * (maxSize * 0.5);

      final offset = Offset(x * w, y * h);

      // glow maior
      canvas.drawCircle(offset, r * 3, glow);
      // ponto claro
      canvas.drawCircle(offset, r, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.particles != particles ||
      oldDelegate.color != color;
}