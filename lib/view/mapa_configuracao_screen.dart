import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/repositories/propriedade_repository.dart';
import 'package:bov_manager/services/propriedade_service.dart';
import 'package:bov_manager/viewmodels/poligono_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
// =============================================================================
// TELA — CONFIGURAR CENTRO DO MAPA DA PROPRIEDADE
// =============================================================================
// Fluxo:
//   1. Usuário busca por cidade/estado ou insere coordenadas manualmente
//   2. O mapa navega para a região encontrada
//   3. Usuário toca no mapa para definir o ponto central
//   4. Confirma com "Salvar" ou descarta com "Cancelar"

class MapaConfiguracaoScreen extends ConsumerStatefulWidget {
  const MapaConfiguracaoScreen({
    super.key,
    this.emVisualizacao = false,
    this.tileProvider,
  });

  /// true = configura a propriedade em visualização (detalhes);
  /// false = configura a propriedade selecionada (dashboard).
  final bool emVisualizacao;

  /// Provider de tiles do mapa. Usado apenas em testes, para evitar
  /// requisições de rede. Quando null (caso do app), o TileLayer usa o
  /// comportamento padrão (NetworkTileProvider), sem nenhuma mudança.
  final TileProvider? tileProvider;

  @override
  ConsumerState<MapaConfiguracaoScreen> createState() =>
      _MapaConfiguracaoScreenState();
}

class _MapaConfiguracaoScreenState
    extends ConsumerState<MapaConfiguracaoScreen> {
  final _buscaController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _mapController = MapController();
  bool _inicializado = false;

  // Ponto selecionado pelo usuário no mapa
  LatLng? _pontoSelecionado;
  bool _isLoading = false;
  String? _erro;

  // Coordenada inicial — Brasil ou centro já salvo na propriedade
  late LatLng _coordenadaInicial;

  String? _cidadeCentroAtual;

  @override
  void dispose() {
    _buscaController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<String?> _buscarCidadeProxima(LatLng ponto) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        ponto.latitude,
        ponto.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final cidade = [
        p.subAdministrativeArea,
        p.administrativeArea,
      ].where((s) => s != null && s.isNotEmpty).join(', ');
      return cidade.isEmpty ? null : cidade;
    } catch (_) {
      return null;
    }
  }

  Future<void> _carregarCidadeCentroAtual(LatLng ponto) async {
    final cidade = await _buscarCidadeProxima(ponto);
    if (!mounted) return;
    setState(() => _cidadeCentroAtual = cidade);
  }

  // ── Busca por nome de cidade/estado ───────────────────────────────────────

  Future<void> _buscarPorNome() async {
    final texto = _buscaController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final locations = await locationFromAddress(texto);
      if (locations.isEmpty) {
        setState(
          () => _erro = 'Local não encontrado. Tente ser mais específico.',
        );
        return;
      }

      final loc = locations.first;
      final destino = LatLng(loc.latitude, loc.longitude);

      _mapController.move(destino, 12);
    } catch (e) {
      setState(
        () => _erro = 'Erro ao buscar localização. Verifique sua conexão.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Navega por coordenadas inseridas manualmente ──────────────────────────

  void _buscarPorCoordenadas() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      setState(() => _erro = 'Coordenadas inválidas. Use formato: -20.123');
      return;
    }

    setState(() => _erro = null);
    _mapController.move(LatLng(lat, lng), 14);
  }

  AsyncValue<List<PoligonoModel>> _watchPoligonos() => widget.emVisualizacao
      ? ref.watch(poligonosListaPropEmVisProvider)
      : ref.watch(poligonosListaProvider);

  Marker _marcador(LatLng ponto, Color cor) {
    return Marker(
      point: ponto,
      width: 32,
      height: 32,
      child: Container(
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.onAccent, width: 2),
        ),
        child: const Icon(
          Icons.place_rounded,
          color: AppColors.onAccent,
          size: 16,
        ),
      ),
    );
  }

  // ── Salva o centro no Firestore ───────────────────────────────────────────

  Future<void> _salvar(PropriedadeModel propriedade) async {
    if (_pontoSelecionado == null) {
      setState(() => _erro = 'Toque no mapa para definir o ponto central.');
      return;
    }

    setState(() => _isLoading = true);

    final cidadeProxima = await _buscarCidadeProxima(_pontoSelecionado!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => BovConfirmacaoCoordenadaDialog(
        lat: _pontoSelecionado!.latitude,
        lng: _pontoSelecionado!.longitude,
        cidadeProxima: cidadeProxima,
        avisoRedefinicao: propriedade.temCentroDefinido,
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(propriedadeRepositoryProvider)
          .salvarCentro(
            propriedadeId: propriedade.id,
            lat: _pontoSelecionado!.latitude,
            lng: _pontoSelecionado!.longitude,
          );

      // A propriedade em visualização é uma cópia local: recarrega do banco
      // para que a tela de detalhes já exiba o centro salvo.
      if (widget.emVisualizacao) {
        final atualizada = await ref
            .read(propriedadeServiceProvider)
            .buscarPorId(propriedadeId: propriedade.id);
        if (atualizada != null) {
          ref
              .read(propriedadeEmVisualizacaoProvider.notifier)
              .abrir(atualizada);
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _erro = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PropriedadeModel?> propriedadeAsync = widget.emVisualizacao
        ? AsyncData(ref.watch(propriedadeEmVisualizacaoProvider))
        : ref.watch(propriedadeSelecionadaProvider);

    final poligonosAsync = _watchPoligonos();

    return propriedadeAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (propriedade) {
        if (propriedade == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: _EmptyState()),
          );
        }

        if (!_inicializado) {
          _coordenadaInicial = propriedade.temCentroDefinido
              ? LatLng(propriedade.centroLat!, propriedade.centroLng!)
              : const LatLng(-15.7801, -47.9292);
          if (propriedade.temCentroDefinido) {
            _pontoSelecionado = _coordenadaInicial;
            final centroAtual = _coordenadaInicial;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _carregarCidadeCentroAtual(centroAtual),
            );
          }
          _inicializado = true;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      BovBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          propriedade.temCentroDefinido
                              ? 'Redefinir centro do mapa'
                              : 'Definir Centro do Mapa',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Painel de busca ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Busca por nome
                      const BovFieldLabel(label: 'BUSCAR POR CIDADE / ESTADO'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: BovTextField(
                              controller: _buscaController,
                              hintText: 'Ex: Corumbá, MS',
                              textInputAction: TextInputAction.search,
                              onChanged: (_) => setState(() => _erro = null),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _isLoading ? null : _buscarPorNome,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.onAccent,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.onAccent,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Busca por coordenadas
                      const BovFieldLabel(
                        label: 'OU INSIRA COORDENADAS (GOOGLE MAPS)',
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BovTextField(
                                  controller: _latController,
                                  hintText: 'Ex: -20.123',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BovTextField(
                                  controller: _lngController,
                                  hintText: 'Ex: -57.456',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _buscarPorCoordenadas,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.text2,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 30),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: BovFieldLabel(label: 'LATITUDE'),
                                ),
                                const Expanded(
                                  child: BovFieldLabel(label: 'LONGITUDE'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Mensagem de erro
                      if (_erro != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _erro!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Instrução
                      Row(
                        children: const [
                          Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.text4,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Toque no mapa para definir o ponto central',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontSize: 12,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // ── Mapa ──────────────────────────────────────────────────
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _coordenadaInicial,
                        initialZoom: propriedade.temCentroDefinido ? 14 : 5,
                        minZoom: 3,
                        maxZoom: 18,
                        onTap: (_, coordenada) {
                          setState(() => _pontoSelecionado = coordenada);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.bov_manager',
                          tileProvider: widget.tileProvider,
                          keepBuffer: 4,
                          tileDisplay: const TileDisplay.fadeIn(),
                        ),

                        // Pastos já desenhados (sempre verdes, sem lotação)
                        poligonosAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (poligonos) => PolygonLayer(
                            polygons: poligonos
                                .map(
                                  (pol) => Polygon(
                                    points: pol.pontos
                                        .map((p) => LatLng(p.lat, p.lng))
                                        .toList(),
                                    // ignore: deprecated_member_use
                                    color: AppColors.pastoVerde.withOpacity(
                                      0.25,
                                    ),
                                    borderColor: AppColors.pastoVerde,
                                    borderStrokeWidth: 2.5,
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                        MarkerLayer(
                          markers: [
                            if (propriedade.temCentroDefinido)
                              _marcador(
                                LatLng(
                                  propriedade.centroLat!,
                                  propriedade.centroLng!,
                                ),
                                AppColors.pastoCinza,
                              ),
                            if (_pontoSelecionado != null &&
                                (!propriedade.temCentroDefinido ||
                                    _pontoSelecionado !=
                                        LatLng(
                                          propriedade.centroLat!,
                                          propriedade.centroLng!,
                                        )))
                              _marcador(
                                _pontoSelecionado!,
                                AppColors.pastoVerde,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (propriedade.temCentroDefinido && _cidadeCentroAtual != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Centro atual: próximo de $_cidadeCentroAtual',
                        style: const TextStyle(
                          color: AppColors.text2,
                          fontSize: 13,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),

                // ── Botões ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: BovSecondaryButton(
                          label: 'Cancelar',
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BovPrimaryButton(
                          label: 'Salvar',
                          isLoading: _isLoading,
                          onPressed: () => _salvar(propriedade),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accentBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.home_work_outlined,
            color: AppColors.accent,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nenhuma propriedade',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cadastre sua primeira fazenda\npara começar a usar o BovManager.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text4,
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: BovPrimaryButton(
            label: 'Cadastrar Propriedade',
            onPressed: () => AppCoordinator.goToNovaPropriedade(context),
          ),
        ),
      ],
    );
  }
}
