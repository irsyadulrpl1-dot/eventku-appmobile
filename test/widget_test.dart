import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventku/widgets/eventku_logo.dart';

void main() {
  testWidgets('EventKu logo shows the brand name', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EventKuLogo(showWordmark: true)),
      ),
    );

    expect(find.text('EventKu'), findsOneWidget);
    expect(find.text('Satu Aplikasi, Semua Event!'), findsOneWidget);
  });
}
