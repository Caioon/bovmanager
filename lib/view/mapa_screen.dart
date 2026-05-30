import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/viewmodels/poligono_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  bool _modoDesenho = false;
  PastoModel? _pastoSelecionado;
  List<PastoModel> _pastos = [];

  final List<LatLng> _pontosDesenho = [];

  final Map<String, int> _contagemAnimais = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarContagens());
  }

  Future<void> _carregarContagens() async {
    final propriedadeId =
        ref.read(propriedadeSelecionadaProvider).value?.id ?? '';
    if (propriedadeId.isEmpty) return;

    final pastos = await ref.read(pastosListaPropSelecionadaProvider.future);
    final service = ref.read(animalServiceProvider);

    final futures = pastos.map((pasto) async {
      final count = await service.contarAnimaisPorPasto(
        propriedadeId: propriedadeId,
        pastoId: pasto.id,
      );
      return MapEntry(pasto.id, count);
    });

    final resultados = await Future.wait(futures);
    if (!mounted) return;
    setState(() {
      _contagemAnimais
        ..clear()
        ..addEntries(resultados);
    });
  }

  Color _corPorLotacao(PoligonoModel pol) {
    if (_modoDesenho) {
      return _pastoSelecionado?.id == pol.pastoId
          ? AppColors.pastoVerde
          : AppColors.pastoCinza;
    }

    final pasto = _pastos.where((p) => p.id == pol.pastoId).firstOrNull;

    if (pasto == null || pasto.limiteAnimais == null) {
      return AppColors.pastoCinza;
    }

    final contagem = _contagemAnimais[pol.pastoId] ?? 0;
    final percentual = contagem / pasto.limiteAnimais!;

    if (percentual <= 0.50) return AppColors.pastoVerde;
    if (percentual <= 0.75) return AppColors.pastoAmarelo;
    if (percentual <= 0.95) return AppColors.pastoLaranja;
    return AppColors.pastoVermelho;
  }

  // Calcula o centroide do polígono (média das lat/lng)
  LatLng _centroide(List<LatLngPoint> pontos) {
    final lat = pontos.map((p) => p.lat).reduce((a, b) => a + b) / pontos.length;
    final lng = pontos.map((p) => p.lng).reduce((a, b) => a + b) / pontos.length;
    return LatLng(lat, lng);
  }

  void _toggleModoDesenho() {
    if (_modoDesenho) {
      setState(() {
        _modoDesenho = false;
        _pastoSelecionado = null;
        _pontosDesenho.clear();
      });
    } else {
      _showSelecionarPasto(_pastos);
    }
  }

  void _adicionarPonto(TapPosition _, LatLng coordenada) {
    if (!_modoDesenho) return;
    setState(() => _pontosDesenho.add(coordenada));
  }

  void _desfazer() {
    if (_pontosDesenho.isEmpty) return;
    setState(() => _pontosDesenho.removeLast());
  }

  void _showSelecionarPasto(List<PastoModel> pastos) {
    if (pastos.isEmpty) {
      showBovErrorSnackBar(
        context,
        'Nenhum pasto cadastrado nesta propriedade.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SelecionarPastoSheet(
        pastos: pastos,
        onSelecionado: (pasto) {
          Navigator.of(context).pop();
          setState(() {
            _pastoSelecionado = pasto;
            _modoDesenho = true;
            _pontosDesenho.clear();
          });
        },
      ),
    );
  }

  Future<void> _salvar() async {
    if (_pontosDesenho.length < 3) {
      showBovErrorSnackBar(context, 'Desenhe pelo menos 3 pontos.');
      return;
    }

    final pontos = _pontosDesenho
        .map((p) => LatLngPoint(lat: p.latitude, lng: p.longitude))
        .toList();

    final sucesso = await ref
        .read(poligonoViewModelProvider.notifier)
        .salvar(pastoId: _pastoSelecionado!.id, pontos: pontos);

    if (!mounted) return;

    if (sucesso) {
      setState(() {
        _modoDesenho = false;
        _pastoSelecionado = null;
        _pontosDesenho.clear();
      });
      _carregarContagens();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Polígono salvo com sucesso!',
            style: TextStyle(color: AppColors.text, fontFamily: 'DM Sans'),
          ),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.accent),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      showBovErrorSnackBar(context, 'Erro ao salvar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final propriedade = ref.watch(propriedadeSelecionadaProvider).value;
    final poligonosAsync = ref.watch(poligonosListaProvider);
    final pastosAsync = ref.watch(pastosListaPropSelecionadaProvider);

    pastosAsync.whenData((lista) => _pastos = lista);

    final centro = (propriedade?.temCentroDefinido ?? false)
        ? LatLng(propriedade!.centroLat!, propriedade.centroLng!)
        : const LatLng(-15.7801, -47.9292);

    final zoomInicial = propriedade?.temCentroDefinido ?? false ? 14.0 : 5.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  BovBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mapa',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        if (_modoDesenho && _pastoSelecionado != null)
                          Text(
                            'Desenhando: ${_pastoSelecionado!.nome}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (_modoDesenho) ...[
                    GestureDetector(
                      onTap: _desfazer,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.undo_rounded,
                          color: AppColors.text2,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _salvar,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  GestureDetector(
                    onTap: _toggleModoDesenho,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _modoDesenho ? AppColors.accent : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _modoDesenho
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        _modoDesenho
                            ? Icons.close_rounded
                            : Icons.edit_rounded,
                        color: _modoDesenho
                            ? AppColors.onAccent
                            : AppColors.text2,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: centro,
                    initialZoom: zoomInicial,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: InteractionOptions(
                      flags: _modoDesenho
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                    ),
                    onTap: _adicionarPonto,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bov_manager',
                      keepBuffer: 4,
                      tileDisplay: const TileDisplay.fadeIn(),
                    ),

                    // Marcador do centro da propriedade
                    if (propriedade?.temCentroDefinido ?? false)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: centro,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.onAccent,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.place_rounded,
                                color: AppColors.onAccent,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Polígonos salvos
                    poligonosAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (poligonos) => PolygonLayer(
                        polygons: poligonos.map((pol) {
                          final color = _corPorLotacao(pol);
                          return Polygon(
                            points: pol.pontos
                                .map((p) => LatLng(p.lat, p.lng))
                                .toList(),
                            // ignore: deprecated_member_use
                            color: color.withOpacity(0.25),
                            borderColor: color,
                            borderStrokeWidth: 2.5,
                          );
                        }).toList(),
                      ),
                    ),

                    // Labels dos polígonos salvos (nome + contagem)
                    poligonosAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (poligonos) => MarkerLayer(
                        markers: poligonos
                            .where((pol) => pol.pontos.length >= 3)
                            .map((pol) {
                          final pasto = _pastos
                              .where((p) => p.id == pol.pastoId)
                              .firstOrNull;
                          final nome = pasto?.nome.toUpperCase() ?? '';
                          final contagem = _contagemAnimais[pol.pastoId] ?? 0;
                          final limite = pasto?.limiteAnimais;
                          final cor = _corPorLotacao(pol);
                          final centroide = _centroide(pol.pontos);

                          return Marker(
                            point: centroide,
                            width: 120,
                            height: 48,
                            child: UnconstrainedBox(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      nome,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'DM Sans',
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    if (limite != null)
                                      Text(
                                        '$contagem/$limite',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Polígono em desenho
                    if (_pontosDesenho.length >= 3)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _pontosDesenho,
                            // ignore: deprecated_member_use
                            color: AppColors.accent.withOpacity(0.25),
                            borderColor: AppColors.accent,
                            borderStrokeWidth: 2.5,
                          ),
                        ],
                      ),

                    if (_pontosDesenho.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _pontosDesenho,
                            color: AppColors.accent,
                            strokeWidth: 2.5,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: _pontosDesenho
                          .map(
                            (p) => Marker(
                              point: p,
                              width: 12,
                              height: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.onAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEET — SELECIONAR PASTO
// =============================================================================

class _SelecionarPastoSheet extends StatelessWidget {
  const _SelecionarPastoSheet({
    required this.pastos,
    required this.onSelecionado,
  });

  final List<PastoModel> pastos;
  final ValueChanged<PastoModel> onSelecionado;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Selecionar Pasto',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'O polígono será associado a este pasto.',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 12,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 16),
            ...pastos.asMap().entries.map((entry) {
              final pasto = entry.value;
              final isFirst = entry.key == 0;
              final isLast = entry.key == pastos.length - 1;
              return GestureDetector(
                onTap: () => onSelecionado(pasto),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: isFirst ? const Radius.circular(12) : Radius.zero,
                      bottom: isLast ? const Radius.circular(12) : Radius.zero,
                    ),
                    border: Border(
                      top: const BorderSide(color: AppColors.border),
                      bottom: isLast
                          ? const BorderSide(color: AppColors.border)
                          : BorderSide.none,
                      left: const BorderSide(color: AppColors.border),
                      right: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.grass_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pasto.nome,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.text4,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
