import 'package:flutter_test/flutter_test.dart';

import 'package:event_discover/main.dart';

void main() {
  testWidgets('Home screen renders greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const EventDiscoverApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('สวัสดี'), findsOneWidget);
  });
}
