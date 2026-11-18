import 'package:flutter/material.dart';

import '../../../../core/network/http_client_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/demand_repository.dart';

class DemandPage extends StatefulWidget {
  const DemandPage({super.key, required this.repository});
  final DemandRepository repository;
  @override
  State<DemandPage> createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _lag1 = TextEditingController();
  final _lag7 = TextEditingController();
  final _mean7 = TextEditingController();
  DemandReport? _report;
  DemandResult? _result;
  String? _product, _error;
  bool _loading = true, _predicting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_date, _lag1, _lag7, _mean7]) {
      c.dispose();
    }
    super.dispose();
  }

  String _message(Object error) => switch (error) {
    UnauthorizedApiException() => 'Tu sesión venció. Vuelve a iniciar sesión.',
    HttpApiException(statusCode: 403) =>
      'Tu usuario no tiene permiso para consultar demanda.',
    NetworkUnavailableException() =>
      'Sin conexión. La predicción necesita consultar el servidor.',
    _ => 'No se pudo consultar la demanda. Inténtalo de nuevo.',
  };
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await widget.repository.load();
      if (!mounted) return;
      setState(() {
        _report = report;
        _select(
          report.scenarios.firstWhere(
            (s) => s.product == 'Hamburguesa',
            orElse: () => report.scenarios.first,
          ),
        );
      });
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(DemandScenario scenario) {
    _product = scenario.product;
    _date.text = scenario.date;
    _lag1.text = scenario.lag1.toString();
    _lag7.text = scenario.lag7.toString();
    _mean7.text = scenario.mean7.toString();
    _result = null;
    _error = null;
  }

  String? _number(String? text) {
    final n = double.tryParse((text ?? '').replaceAll(',', '.'));
    return n == null || !n.isFinite || n < 0 || n > 10000
        ? 'Ingresa un valor entre 0 y 10.000.'
        : null;
  }

  String? _validDate(String? text) {
    final date = DateTime.tryParse(text ?? '');
    return date == null ||
            !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text ?? '') ||
            date.toIso8601String().split('T').first != text
        ? 'Usa una fecha válida: AAAA-MM-DD.'
        : null;
  }

  Future<void> _predict() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _predicting = true;
      _result = null;
      _error = null;
    });
    final request = DemandScenario(
      product: _product!,
      date: _date.text,
      lag1: double.parse(_lag1.text.replaceAll(',', '.')),
      lag7: double.parse(_lag7.text.replaceAll(',', '.')),
      mean7: double.parse(_mean7.text.replaceAll(',', '.')),
    );
    try {
      final result = await widget.repository.predict(request);
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _predicting = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool date = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      enabled: !_predicting,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: date
          ? TextInputType.datetime
          : const TextInputType.numberWithOptions(decimal: true),
      validator: date ? _validDate : _number,
      onChanged: (_) => setState(() {
        _result = null;
        _error = null;
      }),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.parchment,
    appBar: AppBar(title: const Text('Predicción de demanda')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _report == null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error ?? 'No hay información disponible.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Estimar el próximo día',
                style: AppTheme.serif(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Red neuronal · datos sintéticos',
                style: TextStyle(
                  color: AppTheme.lakeBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escenario académico para cinco productos. La historia se ingresa aquí; no se toman los pedidos del restaurante.',
              ),
              const SizedBox(height: 16),
              if (_result != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_result!.units.toStringAsFixed(2).replaceAll('.', ',')} unidades estimadas',
                          key: const Key('demand-result'),
                          style: const TextStyle(
                            fontSize: 25,
                            color: AppTheme.lakeBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${_result!.product} · ${_result!.date}'),
                        const Text(
                          'Estimación del modelo, no una venta garantizada.',
                        ),
                      ],
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ),
              Form(
                key: _form,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _product,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Producto académico',
                        border: OutlineInputBorder(),
                      ),
                      items: _report!.scenarios
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.product,
                              child: Text(s.product),
                            ),
                          )
                          .toList(),
                      onChanged: _predicting
                          ? null
                          : (value) => setState(
                              () => _select(
                                _report!.scenarios.firstWhere(
                                  (s) => s.product == value,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    _field(_date, 'Fecha a estimar', date: true),
                    _field(_lag1, 'Unidades del día anterior'),
                    _field(_lag7, 'Unidades de hace 7 días'),
                    _field(_mean7, 'Promedio de los últimos 7 días'),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _predicting ? null : _predict,
                        icon: const Icon(Icons.auto_graph),
                        label: Text(
                          _predicting ? 'Consultando…' : 'Estimar unidades',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_report!.modelId != null) Text('Modelo ${_report!.modelId}'),
              Text(
                'Error absoluto medio: ${_report!.mae.toStringAsFixed(2).replaceAll('.', ',')} unidades en prueba sintética.',
              ),
              const Text(
                'El servidor ejecuta los pesos entrenados. Esta consulta no vuelve a entrenar la red.',
              ),
            ],
          ),
  );
}
