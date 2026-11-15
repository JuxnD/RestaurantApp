import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantapp/core/network/http_client_service.dart';
import 'package:restaurantapp/features/administrator/data/repositories/demand_repository.dart';
import 'package:restaurantapp/features/administrator/presentation/pages/demand_page.dart';

class FakeDemandHttp extends HttpClientService {
  int predictions = 0;
  bool fail = false, malformed = false;
  String? lastUrl;
  Map<String, dynamic>? lastBody;
  @override
  Future<dynamic> get(
    String url, {
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    lastUrl = url;
    if (fail) throw const NetworkUnavailableException();
    return {
      'examples': malformed
          ? []
          : [
              {
                'request': {
                  'product': 'Hamburguesa',
                  'date': '2026-09-01',
                  'lag1': 38,
                  'lag7': 40,
                  'mean7': 65.71428571428571,
                },
              },
              {
                'request': {
                  'product': 'Pizza',
                  'date': '2026-09-01',
                  'lag1': 34,
                  'lag7': 39,
                  'mean7': 45.285714285714285,
                },
              },
            ],
      'metrics': {
        'Red neuronal': {'MAE': 3.171572208404541},
      },
    };
  }

  @override
  Future<dynamic> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    predictions++;
    lastBody = body;
    lastUrl = url;
    if (fail) throw const NetworkUnavailableException();
    return {
      'product': body['product'],
      'date': body['date'],
      'units': 45.27287608318317,
    };
  }
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  Future<void> open(WidgetTester t, FakeDemandHttp client) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(home: DemandPage(repository: DemandRepository(client))),
    );
    await t.pumpAndSettle();
  }

  Future<void> predict(WidgetTester t) async {
    final b = find.text('Estimar unidades');
    await t.ensureVisible(b);
    await t.pumpAndSettle();
    await t.tap(b);
    await t.pumpAndSettle();
  }

  testWidgets(
    'posts scenario and renders units, not a success-only placeholder',
    (t) async {
      final client = FakeDemandHttp();
      await open(t, client);
      await predict(t);
      expect(client.lastUrl, endsWith('/api/admin/demand/predict'));
      expect(client.lastBody, {
        'product': 'Hamburguesa',
        'date': '2026-09-01',
        'lag1': 38.0,
        'lag7': 40.0,
        'mean7': 65.71428571428571,
      });
      await t.ensureVisible(find.byKey(const Key('demand-result')));
      expect(find.text('45,27 unidades estimadas'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.enterText(
        find.widgetWithText(TextFormField, 'Unidades del día anterior'),
        '50',
      );
      await t.pump();
      expect(find.byKey(const Key('demand-result')), findsNothing);
    },
  );
  testWidgets(
    'rejects invalid calendar date and negative history before posting',
    (t) async {
      final client = FakeDemandHttp();
      await open(t, client);
      await t.enterText(
        find.widgetWithText(TextFormField, 'Fecha a estimar'),
        '2026-02-30',
      );
      await t.enterText(
        find.widgetWithText(TextFormField, 'Unidades del día anterior'),
        '-1',
      );
      await predict(t);
      expect(client.predictions, 0);
      expect(find.text('Usa una fecha válida: AAAA-MM-DD.'), findsOneWidget);
      expect(find.text('Ingresa un valor entre 0 y 10.000.'), findsOneWidget);
    },
  );
  testWidgets(
    'connection failure does not leave a stale prediction; retry succeeds',
    (t) async {
      final client = FakeDemandHttp();
      await open(t, client);
      await predict(t);
      client.fail = true;
      await predict(t);
      expect(find.byKey(const Key('demand-result')), findsNothing);
      expect(find.textContaining('Sin conexión.'), findsOneWidget);
      client.fail = false;
      await predict(t);
      expect(find.text('45,27 unidades estimadas'), findsOneWidget);
    },
  );
  testWidgets('empty report is an error, retry reloads real options', (
    t,
  ) async {
    final client = FakeDemandHttp()..malformed = true;
    await open(t, client);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Estimar unidades'), findsNothing);
    client.malformed = false;
    await t.tap(find.text('Reintentar'));
    await t.pumpAndSettle();
    expect(find.text('Hamburguesa'), findsOneWidget);
  });
}
