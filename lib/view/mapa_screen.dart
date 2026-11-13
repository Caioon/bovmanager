import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/view/novo_pasto_screen.dart';
import 'package:bov_manager/viewmodels/poligono_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({
    super.key,
    this.emVisualizacao = false,
    this.tileProvider,
  });

  /// true = usa a propriedade em visualização (vinda dos detalhes);
  /// false = usa a propriedade selecionada (dashboard).
  final bool emVisualizacao;

  /// Provider de tiles do mapa. Usado apenas em testes, para evitar
  /// requisições de rede. Quando null (caso do app), o TileLayer usa o
  /// comportamento padrão (NetworkTileProvider), sem nenhuma mudança.
  final TileProvider? tileProvider;

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  // Helpers que escolhem o provider conforme a origem (visualização/selecionada).
  Future<List<PastoModel>> _lerPastos() => widget.emVisualizacao
      ? ref.read(pastosListaPropEmVisualizacaoProvider.future)
      : ref.read(pastosListaPropSelecionadaProvider.future);

  void _invalidarPastos() => widget.emVisualizacao
      ? ref.invalidate(pastosListaPropEmVisualizacaoProvider)
      : ref.invalidate(pastosListaPropSelecionadaProvider);

  AsyncValue<List<PastoModel>> _watchPastos() => widget.emVisualizacao
      ? ref.watch(pastosListaPropEmVisualizacaoProvider)
      : ref.watch(pastosListaPropSelecionadaProvider);

  AsyncValue<List<PoligonoModel>> _watchPoligonos() => widget.emVisualizacao
      ? ref.watch(poligonosListaPropEmVisProvider)
      : ref.watch(poligonosListaProvider);

  String? get _propriedadeId => widget.emVisualizacao
      ? ref.read(propriedadeEmVisualizacaoProvider)?.id
      : ref.read(propriedadeSelecionadaProvider).value?.id;

  bool _modoDesenho = false;
  PastoModel? _pastoSelecionado;
  List<PastoModel> _pastos = [];
  Set<String> _pastosComArea = {};

  final List<LatLng> _pontosDesenho = [];

  // Pilha de pontos desfeitos, usada pelo botão "Refazer".
  final List<LatLng> _pontosRefazer = [];

  final Map<String, int> _contagemAnimais = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarContagens());
  }

  Future<void> _carregarContagens() async {
    final propriedadeId = _propriedadeId ?? '';
    if (propriedadeId.isEmpty) return;

    final pastos = await _lerPastos();
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

  void _adicionarPonto(TapPosition _, LatLng coordenada) {
    if (!_modoDesenho) return;
    setState(() {
      _pontosDesenho.add(coordenada);
      // Um novo ponto invalida o histórico de "refazer".
      _pontosRefazer.clear();
    });
  }

  void _desfazer() {
    if (_pontosDesenho.isEmpty) return;
    setState(() => _pontosRefazer.add(_pontosDesenho.removeLast()));
  }

  void _refazer() {
    if (_pontosRefazer.isEmpty) return;
    setState(() => _pontosDesenho.add(_pontosRefazer.removeLast()));
  }

  void _cancelarDesenho() {
    setState(() {
      _modoDesenho = false;
      _pastoSelecionado = null;
      _pontosDesenho.clear();
      _pontosRefazer.clear();
    });
  }

  Future<void> _confirmarConclusao() async {
    if (_pontosDesenho.length < 3) {
      showBovErrorSnackBar(context, 'Desenhe pelo menos 3 pontos.');
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Confirmar alterações',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        content: Text(
          'Deseja salvar o polígono do pasto '
          '"${_pastoSelecionado?.nome ?? ''}"?',
          style: const TextStyle(
            color: AppColors.text2,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.text2,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou == true) await _salvar();
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
        pastosComArea: _pastosComArea,
        onSelecionado: (pasto) {
          Navigator.of(context).pop();
          setState(() {
            _pastoSelecionado = pasto;
            _modoDesenho = true;
            _pontosDesenho.clear();
            _pontosRefazer.clear();
          });
        },
      ),
    );
  }

  Future<void> _abrirNovoPasto() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NovoPastoScreen(
          propriedadeId: widget.emVisualizacao ? _propriedadeId : null,
        )),
    );
    if (!mounted) return;

    // Força o recarregamento da lista de pastos e aguarda o resultado, para
    // que o novo pasto já apareça no seletor de "Desenhar áreas".
    _invalidarPastos();
    final pastos = await _lerPastos();
    if (!mounted) return;
    setState(() => _pastos = pastos);
    _carregarContagens();
  }

  Future<void> _salvar() async {
    if (_pontosDesenho.length < 3) {
      showBovErrorSnackBar(context, 'Desenhe pelo menos 3 pontos.');
      return;
    }

    final pasto = _pastoSelecionado!;
    final pontosOriginais = List<LatLng>.of(_pontosDesenho);
    final pontos = pontosOriginais
        .map((p) => LatLngPoint(lat: p.latitude, lng: p.longitude))
        .toList();

    setState(() {
      _modoDesenho = false;
      _pastoSelecionado = null;
      _pontosDesenho.clear();
      _pontosRefazer.clear();
    });

    bool sucesso;
    try {
      sucesso = await ref
          .read(poligonoViewModelProvider.notifier)
          .salvar(
            pastoId: pasto.id,
            pontos: pontos,
            propriedadeId: _propriedadeId,
          );
    } catch (_) {
      sucesso = false;
    }

    if (!mounted) return;

    if (sucesso) {
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
      setState(() {
        _modoDesenho = true;
        _pastoSelecionado = pasto;
        _pontosDesenho
          ..clear()
          ..addAll(pontosOriginais);
      });
      showBovErrorSnackBar(context, 'Erro ao salvar. Tente novamente.');
    }
  }

  Widget _buildBotoesFlutuantes() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 80,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _modoDesenho
            ? Row(
                key: const ValueKey('botoes-edicao'),
                children: [
                  Expanded(
                    child: _BotaoFlutuante(
                      icon: Icons.undo_rounded,
                      label: 'Desfazer',
                      onTap: _pontosDesenho.isEmpty ? null : _desfazer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BotaoFlutuante(
                      icon: Icons.redo_rounded,
                      label: 'Refazer',
                      onTap: _pontosRefazer.isEmpty ? null : _refazer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BotaoFlutuante(
                      icon: _pontosDesenho.isEmpty
                          ? Icons.close_rounded
                          : Icons.check_rounded,
                      label: _pontosDesenho.isEmpty ? 'Cancelar' : 'Concluir',
                      destaque: true,
                      onTap: _pontosDesenho.isEmpty
                          ? _cancelarDesenho
                          : _confirmarConclusao,
                    ),
                  ),
                ],
              )
            : _pastos.isEmpty
                ? Center(
                    key: const ValueKey('botao-novo-pasto'),
                    child: _BotaoFlutuante(
                      icon: Icons.add_rounded,
                      label: 'Novo pasto',
                      destaque: true,
                      onTap: _abrirNovoPasto,
                    ),
                  )
                : Row(
                    key: const ValueKey('botoes-iniciais'),
                    children: [
                      Expanded(
                        child: _BotaoFlutuante(
                          icon: Icons.add_rounded,
                          label: 'Novo pasto',
                          onTap: _abrirNovoPasto,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BotaoFlutuante(
                          icon: Icons.edit_rounded,
                          label: 'Desenhar áreas',
                          destaque: true,
                          onTap: () => _showSelecionarPasto(_pastos),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propriedade = widget.emVisualizacao
        ? ref.watch(propriedadeEmVisualizacaoProvider)
        : ref.watch(propriedadeSelecionadaProvider).value;
    final poligonosAsync = _watchPoligonos();
    final pastosAsync = _watchPastos();

    pastosAsync.whenData((lista) => _pastos = lista);
    poligonosAsync.whenData(
      (lista) => _pastosComArea = lista
          .where((pol) => pol.pontos.length >= 3)
          .map((pol) => pol.pastoId)
          .toSet(),
    );

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
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                ClipRRect(
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
                      tileProvider: widget.tileProvider,
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
                _buildBotoesFlutuantes(),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BOTÃO FLUTUANTE
// =============================================================================

class _BotaoFlutuante extends StatelessWidget {
  const _BotaoFlutuante({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final corFundo = destaque ? AppColors.accent : AppColors.card;
    final corConteudo = destaque ? AppColors.onAccent : AppColors.text2;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: habilitado ? 1 : 0.45,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: destaque ? AppColors.accent : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: corConteudo, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: corConteudo,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
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
    required this.pastosComArea,
    required this.onSelecionado,
  });

  final List<PastoModel> pastos;
  final Set<String> pastosComArea;
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
              final temArea = pastosComArea.contains(pasto.id);
              final corLabel =
                  temArea ? AppColors.pastoVerde : AppColors.pastoAmarelo;
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: corLabel.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: corLabel.withAlpha(140)),
                        ),
                        child: Text(
                          temArea ? 'Com área' : 'Sem área',
                          style: TextStyle(
                            color: corLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
