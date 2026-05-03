import 'package:flutter_test/flutter_test.dart';
import 'package:pickleball/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PickleballScorekeeperApp());
    await tester.pumpAndSettle();
    
    expect(find.text('Match Type'), findsOneWidget);
  });
}