import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_family/widgets/status_badge.dart';
import 'package:power_family/widgets/stat_card.dart';

void main() {
  testWidgets('Widgets render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: 'available'),
              StatCard(title: 'Properties', value: '12', icon: Icons.home),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.byType(StatCard), findsOneWidget);
    expect(find.text('PROPERTIES'), findsNothing);
    expect(find.text('Properties'), findsOneWidget);
  });
}
