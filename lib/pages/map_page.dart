// lib/pages/map_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/geo_service.dart'; // já criamos antes

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _map = MapController();
  LatLng? _center;
  String? _place;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final pos = await GeoService.currentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      final place = await GeoService.reverseGeocode(
        latLng.latitude,
        latLng.longitude,
      );
      setState(() {
        _center = latLng;
        _place = place;
        _loading = false;
      });

      // anima o foco pro usuário
      unawaited(_map.move(latLng, 16));
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao obter localização: $e')),
        );
      }
    }
  }

  Future<void> _recenter() async {
    if (_center == null) return;
    _map.move(_center!, 16);
  }

  Future<void> _confirmarLocal() async {
    final text = _place ?? 'Local próximo';
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmar local',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local confirmado!')),
                );
                // 👉 aqui depois salvamos no Supabase (mercado + ponto)
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Confirmar local',
            onPressed: _confirmarLocal,
            icon: const Icon(Icons.verified_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_center == null)
              ? const Center(child: Text('Sem localização disponível'))
              : FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _center!,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.buybetter.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center!,
                          width: 56,
                          height: 56,
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 36,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      floatingActionButton: _center == null
          ? null
          : FloatingActionButton.small(
              tooltip: 'Centralizar',
              onPressed: _recenter,
              child: const Icon(Icons.my_location_rounded),
            ),
    );
  }
}