import '../../../../core/network/api_config.dart';
import '../../../../core/network/http_client_service.dart';

class DemandScenario {
  const DemandScenario({
    required this.product,
    required this.date,
    required this.lag1,
    required this.lag7,
    required this.mean7,
  });
  final String product, date;
  final double lag1, lag7, mean7;
  Map<String, dynamic> toJson() => {
    'product': product,
    'date': date,
    'lag1': lag1,
    'lag7': lag7,
    'mean7': mean7,
  };
  factory DemandScenario.fromJson(Map<String, dynamic> json) => DemandScenario(
    product: json['product'] as String,
    date: json['date'] as String,
    lag1: (json['lag1'] as num).toDouble(),
    lag7: (json['lag7'] as num).toDouble(),
    mean7: (json['mean7'] as num).toDouble(),
  );
}

class DemandReport {
  DemandReport({required this.scenarios, required this.mae, this.modelId});
  final List<DemandScenario> scenarios;
  final double mae;
  final String? modelId;
  factory DemandReport.fromJson(Map<String, dynamic> json) {
    final scenarios = (json['examples'] as List)
        .map(
          (e) => DemandScenario.fromJson(
            Map<String, dynamic>.from(e['request'] as Map),
          ),
        )
        .toList();
    final mae = (json['metrics']['Red neuronal']['MAE'] as num).toDouble();
    if (scenarios.isEmpty || !mae.isFinite || mae < 0) {
      throw const FormatException('Informe de demanda inválido.');
    }
    return DemandReport(
      scenarios: scenarios,
      mae: mae,
      modelId: json['modelId'] as String?,
    );
  }
}

class DemandResult {
  const DemandResult({
    required this.product,
    required this.date,
    required this.units,
  });
  final String product, date;
  final double units;
}

/// Reuses the authenticated Spring client; inference stays on the backend.
class DemandRepository {
  DemandRepository(this.client);
  final HttpClientService client;
  Future<DemandReport> load() async => DemandReport.fromJson(
    Map<String, dynamic>.from(
      await client.get('${ApiConfig.baseUrl}/api/admin/demand/report') as Map,
    ),
  );
  Future<DemandResult> predict(DemandScenario scenario) async {
    final data = await client.post(
      '${ApiConfig.baseUrl}/api/admin/demand/predict',
      body: scenario.toJson(),
    );
    final units = (data['units'] as num).toDouble();
    if (!units.isFinite ||
        units < 0 ||
        data['product'] != scenario.product ||
        data['date'] != scenario.date) {
      throw const FormatException(
        'La respuesta no coincide con el escenario solicitado.',
      );
    }
    return DemandResult(
      product: scenario.product,
      date: scenario.date,
      units: units,
    );
  }
}
