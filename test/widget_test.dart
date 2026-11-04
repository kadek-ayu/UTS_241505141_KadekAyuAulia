
import 'package:flutter_test/flutter_test.dart';
import 'package:apotech_flutter_uts/app.dart';

void main() {
  testWidgets('ApoTech app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApoTechApp());

    expect(find.text('ApoTech'), findsOneWidget);
  });
}
