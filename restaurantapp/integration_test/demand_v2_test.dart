import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantapp/core/network/api_config.dart';
import 'package:restaurantapp/core/network/http_client_service.dart';
import 'package:restaurantapp/core/session/session_manager.dart';
import 'package:restaurantapp/features/auth/domain/entities/auth_user.dart';
import 'package:restaurantapp/features/administrator/data/repositories/demand_repository.dart';
import 'package:restaurantapp/features/administrator/presentation/pages/demand_page.dart';

class BoundaryClient extends HttpClientService {
  BoundaryClient(SessionManager session)
    : super(
        sessionManager: session,
        timeoutDuration: const Duration(seconds: 3),
      );

  @override
  Future<dynamic> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    final result = await super.post(
      url,
      body: body,
      requiresAuth: requiresAuth,
    );
    if (const bool.fromEnvironment('DEMAND_MUTANT') &&
        url.endsWith('/api/admin/demand/predict')) {
      result['units'] = (result['units'] as num) + 10;
    }
    return result;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'v2 real API and native UI, five products, roles and network recovery',
    (tester) async {
      const base = 'http://127.0.0.1:15454';
      ApiConfig.setBaseUrl(base);
      final session = await SessionManager.getInstance();
      final client = BoundaryClient(session);
      final login = await client.post(
        '$base/auth/signin',
        body: {'email': 'cocina-aula@example.test', 'password': 'AulaDemo2026'},
        requiresAuth: false,
      );
      await session.saveSession(
        token: login['jwt'],
        user: const AuthUser(
          fullName: 'Cocina Aula QA',
          email: 'cocina-aula@example.test',
          role: AuthRole.restaurantOwner,
        ),
      );
      final response = await http.get(
        Uri.parse('$base/api/admin/demand/report'),
        headers: {'Authorization': 'Bearer ${login['jwt']}'},
      );
      expect(response.statusCode, 200);
      final report = jsonDecode(response.body) as Map<String, dynamic>;
      expect(report['modelId'], 'demanda-mlp-v2-seed42');
      expect(
        (report['metrics']['Red neuronal']['MAE'] as num).toDouble(),
        closeTo(3.0503864, 0.0001),
      );
      await tester.pumpWidget(
        MaterialApp(home: DemandPage(repository: DemandRepository(client))),
      );

      Future<void> waitFor(Finder finder) async {
        for (var i = 0; i < 120 && finder.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(finder, findsOneWidget);
      }

      Future<void> estimate() async {
        final button = find.text('Estimar unidades');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
      }

      await waitFor(find.text('Estimar unidades'));
      for (final example in report['examples'] as List) {
        final product = example['request']['product'] as String;
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(product).last);
        await tester.pumpAndSettle();
        await estimate();
        await waitFor(find.byKey(const Key('demand-result')));
        final expected = (example['expected'] as num)
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        expect(
          find.text('$expected unidades estimadas'),
          findsOneWidget,
          reason: 'V2 prediction must match frozen Keras result',
        );
      }
      ApiConfig.setBaseUrl('http://127.0.0.1:1');
      await estimate();
      await waitFor(find.textContaining('Sin conexión.'));
      expect(find.byKey(const Key('demand-result')), findsNothing);
      ApiConfig.setBaseUrl(base);
      await estimate();
      await waitFor(find.byKey(const Key('demand-result')));
      for (final role in ['cliente', 'gerente', 'admin']) {
        final account = await client.post(
          '$base/auth/signin',
          body: {
            'email': '$role-aula@example.test',
            'password': 'AulaDemo2026',
          },
          requiresAuth: false,
        );
        final access = await http.get(
          Uri.parse('$base/api/admin/demand/report'),
          headers: {'Authorization': 'Bearer ${account['jwt']}'},
        );
        expect(access.statusCode, role == 'admin' ? 200 : 403);
      }
      expect(tester.takeException(), isNull);
      await session.clearSession();
    },
  );
}
