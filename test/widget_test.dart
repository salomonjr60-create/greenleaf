import 'package:flutter_test/flutter_test.dart';
import 'package:greenleaf/main.dart';

void main() {
  testWidgets('Greenleaf app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenLeafApp());
    expect(find.text('greenleaf'), findsWidgets);
  });
}
