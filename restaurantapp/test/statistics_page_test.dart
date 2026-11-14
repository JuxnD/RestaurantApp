import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantapp/features/administrator/presentation/pages/statistics_page.dart';
import 'package:restaurantapp/features/customer/domain/entities/order.dart';

CustomerOrder order(
  String id,
  String paid,
  String status,
  int day,
  double total,
) => CustomerOrder(
  id: id,
  customerName: 'Demo',
  customerEmail: 'demo@example.test',
  items: [],
  deliveryAddress: const Address(
    street: 'Aula',
    city: 'Cartagena',
    postalCode: '130001',
  ),
  paymentMethod: const PaymentMethod(type: 'test', details: 'local'),
  paymentStatus: paid,
  status: status,
  createdAt: DateTime(2026, 11, day),
  finalTotal: total,
);
void main() {
  test('paid revenue excludes unpaid and cancelled, deduplicates and fills zero days', () {
    final a = order('1', 'paid', 'delivered', 13, 15000);
    final s = SalesSummary([
      a,
      a,
      order('2', 'pending', 'pending', 14, 90000),
      order('3', 'paid', 'cancelled', 14, 20000),
      order('4', 'paid', 'preparing', 14, 30000),
    ]);
    expect(s.total, 45000);
    expect(s.count, 4);
    expect(s.paidCount, 2);
    expect(s.revenue, [0, 0, 0, 0, 0, 15000, 30000]);
    expect(s.statuses['Cancelado'], 1);
  });
  testWidgets('empty state and 390px charts render without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatisticsPage(orders: [])),
      ),
    );
    expect(find.text('Aún no hay pedidos para graficar.'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticsPage(
            orders: [order('1', 'paid', 'delivered', 14, 15000)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ventas pagadas por día'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Pedidos por estado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
