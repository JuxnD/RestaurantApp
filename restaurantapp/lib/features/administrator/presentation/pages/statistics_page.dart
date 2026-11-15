import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/order.dart';
import '../../../customer/domain/entities/product.dart';

class SalesSummary {
  SalesSummary(List<CustomerOrder> orders) {
    final unique = {for (final order in orders) order.id: order}.values
        .toList();
    count = unique.length;
    final paid = unique
        .where((o) => o.paymentStatus == 'paid' && o.status != 'cancelled')
        .toList();
    total = paid.fold(0, (value, o) => value + o.total);
    paidCount = paid.length;
    for (final o in unique) {
      final label = switch (o.status) {
        'pending' => 'Pendiente',
        'preparing' => 'Preparando',
        'ready' => 'Listo',
        'delivered' => 'Entregado',
        'cancelled' => 'Cancelado',
        _ => 'Otro / sin sincronizar',
      };
      statuses[label] = (statuses[label] ?? 0) + 1;
    }
    if (unique.isEmpty) return;
    final last = unique
        .map((o) => o.createdAt.toLocal())
        .reduce((a, b) => a.isAfter(b) ? a : b);
    end = DateTime(last.year, last.month, last.day);
    for (var i = 6; i >= 0; i--) {
      final date = DateTime(end!.year, end!.month, end!.day - i);
      days.add(date);
      revenue.add(
        paid
            .where((o) {
              final d = o.createdAt.toLocal();
              return d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day;
            })
            .fold(0.0, (value, o) => value + o.total),
      );
    }
  }
  int count = 0, paidCount = 0;
  double total = 0;
  DateTime? end;
  final days = <DateTime>[];
  final revenue = <double>[];
  final statuses = <String, int>{};
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.orders, this.onOpenDemand});
  final List<CustomerOrder> orders;
  final VoidCallback? onOpenDemand;
  @override
  Widget build(BuildContext context) {
    final summary = SalesSummary(orders);
    final maxCount = summary.statuses.values.fold(1, math.max);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Estadísticas',
          style: AppTheme.serif(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pedidos cargados de este restaurante. Las ventas incluyen pagos confirmados y excluyen cancelados.',
        ),
        const SizedBox(height: 18),
        if (onOpenDemand != null) ...[
          OutlinedButton.icon(onPressed: onOpenDemand, icon: const Icon(Icons.auto_graph),
            label: const Text('Predicción de demanda · IA')),
          const SizedBox(height: 12),
        ],
        Text(
          formatCop(summary.total),
          style: AppTheme.serif(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(
          '${summary.paidCount} pagos confirmados · ${summary.count} pedidos cargados',
        ),
        const SizedBox(height: 24),
        if (summary.count == 0)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Aún no hay pedidos para graficar.'),
          ),
        if (summary.count > 0) ...[
          _Panel(
            title: 'Ventas pagadas por día',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 días hasta ${summary.end!.day}/${summary.end!.month}/${summary.end!.year} · COP',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 165,
                  width: double.infinity,
                  child: Semantics(
                    label:
                        'Gráfica de ventas pagadas. Valores detallados debajo.',
                    child: CustomPaint(painter: _SalesLine(summary.revenue)),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < summary.days.length; i++)
                      Text(
                        '${summary.days[i].day}/${summary.days[i].month}  ${formatCop(summary.revenue[i])}',
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Pedidos por estado',
            child: Column(
              children: [
                for (final item in summary.statuses.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.key} · ${item.value}'),
                        const SizedBox(height: 5),
                        Semantics(
                          label: '${item.key}, ${item.value} pedidos',
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: item.value / maxCount),
                            duration: const Duration(milliseconds: 350),
                            builder: (context, value, child) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 14,
                                color: AppTheme.lakeBlue,
                                backgroundColor: AppTheme.periwinkle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Líneas para ver la evolución diaria; barras para comparar estados. Se usan los pedidos recibidos del backend, sin estimaciones de ventas.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Los modelos de categoría y demanda están disponibles en el panel web.',
          style: TextStyle(color: AppTheme.graphite),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppTheme.ash),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.serif(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _SalesLine extends CustomPainter {
  _SalesLine(this.values);
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = values.fold(1.0, math.max);
    const left = 56.0;
    final bottom = size.height - 18;
    final height = bottom - 12;
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = bottom - fraction * height;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - 5, y),
        Paint()
          ..color = AppTheme.ash
          ..strokeWidth = 1,
      );
      final label = max * fraction >= 1000
          ? '${(max * fraction / 1000).toStringAsFixed(0)} mil'
          : (max * fraction).toStringAsFixed(0);
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: AppTheme.graphite, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(0, y - 6));
    }
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          left + i * (size.width - left - 5) / math.max(1, values.length - 1),
          bottom - values[i] / max * height,
        ),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.lakeBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = AppTheme.lakeBlue);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesLine oldDelegate) => true;
}
