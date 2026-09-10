// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:artisan_hub/main.dart';
import 'package:artisan_hub/providers/product_draft_provider.dart';

void main() {
  testWidgets('CraftBridge app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProductDraftScope(
        provider: ProductDraftProvider(),
        child: const ArtisanHubApp(),
      ),
    );

    // Verify OnboardingScreen loads with CraftBridge title.
    expect(find.textContaining('CraftBridge'), findsWidgets);
  });
}
