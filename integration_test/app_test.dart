import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:menu_qr/screens/home_18.dart';
import 'package:mockito/mockito.dart';
import 'package:integration_test/integration_test.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

final logger = Logger();

void dump() {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Test open menu widget', (tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: const Home18(
          changeToDark: dump,
          changeToLight: dump,
        ),
        navigatorObservers: [mockObserver],
      ),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byKey(const ValueKey('Setting')));
    expect(buttonFinder, findsOneWidget, reason: 'Không tìm thấy button');

    final listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget, reason: 'Không tìm thấy ListView');

    final listViewWidget = tester.widget<ListView>(listViewFinder);
    expect(listViewWidget, isNotNull,
        reason: 'Không lấy được instance của ListView');

    final buttonFinderOffset = tester.getCenter(buttonFinder);
    await tester.tapAt(buttonFinderOffset); // AWAIT HERE

    await tester.pumpAndSettle();

    final btnMenuSetting = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byKey(const ValueKey('ButtonMenuId')));

    final btnMenuSettingOffset = tester.getCenter(btnMenuSetting);
    await tester.tapAt(btnMenuSettingOffset); // AWAIT HERE

    await tester.pumpAndSettle();

    final textFieldMenuFinder = find.byKey(const ValueKey('titleMenuField'));
    expect(textFieldMenuFinder, findsOneWidget,
        reason: 'Không tìm thấy textField');

    await tester.enterText(textFieldMenuFinder, 'NewMenu123'); // AWAIT HERE
    await tester.pumpAndSettle();

    final textFieldMenu = tester.widget<TextField>(textFieldMenuFinder);
    logger.i("${textFieldMenu.controller?.text}");
    expect(
        textFieldMenu.controller?.text, 'NewMenu123'); // Now this should work
  });
}
