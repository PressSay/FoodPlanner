import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_qr/screens/home_18.dart';
import 'package:menu_qr/screens/settings/setting_17.dart';
import 'package:mockito/mockito.dart';
import 'package:integration_test/integration_test.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Test open menu widget', (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        // Đảm bảo có MaterialApp
        home: const Home18(),
        navigatorObservers: [mockObserver],
      ),
    );
    await tester.pumpAndSettle();

    final titleSetting = find.byKey(const ValueKey('Setting'));
    expect(titleSetting, findsOneWidget,
        reason: 'Không tìm thấy widget Setting');

    final buttonFinder =
        find.ancestor(of: find.byType(ElevatedButton), matching: titleSetting);
    expect(buttonFinder, findsOneWidget, reason: 'Không tìm thấy button');

    // Tìm ListView
    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget, reason: 'Không tìm thấy ListView');

    // Lấy instance của ListView
    final listViewWidget = tester.widget<ListView>(listViewFinder);
    expect(listViewWidget, isNotNull,
        reason: 'Không lấy được instance của ListView');

    // Cuộn
    // await tester.scrollUntilVisible(buttonFinder, 500.0);
    // await tester.pumpAndSettle();

    final center = tester.getCenter(buttonFinder);
    await tester.tapAt(center);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(
        MaterialPageRoute(builder: (BuildContext context) => Setting17()),
        null));
  });
}
