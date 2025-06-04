import 'package:flutter/material.dart';
import 'package:flutter_net_printer_example/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Main App Integration Test', () {
    testWidgets('UI loads and shows no printers found', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Plugin example app'), findsOneWidget);
      expect(find.text('No printers found'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Print Test'), findsOneWidget);
      expect(find.text('Check Device Availability'), findsOneWidget);
    });

    testWidgets(
      'Enter IP and Port, tap Print Test and Check Device Availability',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Enter IP address
        await tester.enterText(find.byType(TextField).at(0), '192.168.1.100');
        // Enter Port
        await tester.enterText(find.byType(TextField).at(1), '9100');
        await tester.pump();

        // Tap Print Test
        await tester.tap(find.text('Print Test'));
        await tester.pumpAndSettle();

        // Tap Check Device Availability
        await tester.tap(find.text('Check Device Availability'));
        await tester.pumpAndSettle();

        // Since device is not available, expect red snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Device is not available'), findsOneWidget);
      },
    );

    testWidgets('Show snackbar for available device', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter IP address
      await tester.enterText(find.byType(TextField).at(0), '127.0.0.1');
      // Enter Port
      await tester.enterText(find.byType(TextField).at(1), '9100');
      await tester.pump();

      // Tap Check Device Availability
      await tester.tap(find.text('Check Device Availability'));
      await tester.pumpAndSettle();

      // Since device is not available, expect red snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
