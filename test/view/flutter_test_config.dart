import 'dart:async';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await runZoned(
    testMain,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        // Esse arquivo deveria suprimir logs de rede do TileLayer do flutter_map
        // Logs que seriam relacionados a erros de busca de imagens, por conta de que os testes
        // não possuem um user-agent aceitavel para buscar elas. Isso não influencia nos testes finais.
        if (line.contains('openstreetmap') ||
            line.contains('ClientException') ||
            line.contains('tile.openstreetmap')) {
          return;
        }
        parent.print(zone, line);
      },
    ),
  );
}
