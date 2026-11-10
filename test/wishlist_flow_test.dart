import 'package:ceramic_app/main.dart';
import 'package:ceramic_app/models/user_data_manager.dart';
import 'package:ceramic_app/screens/detail_screen.dart';
import 'package:ceramic_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('guest can reopen a saved favorite and remove it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ko_KR');
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> openApp() async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UserDataManager(),
          child: const MaterialApp(home: MainScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    await openApp();
    final card = find.byType(ProductCard).first;
    await tester.ensureVisible(card);
    final product = tester.widget<ProductCard>(card).product;
    await tester.tap(find.descendant(
      of: card,
      matching: find.byTooltip('찜 추가'),
    ));
    await tester.pumpAndSettle();
    expect(find.descendant(of: card, matching: find.byTooltip('찜 해제')),
        findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await openApp();
    await tester.tap(find.byTooltip('찜한 상품'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, product.title));
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.byTooltip('찜 해제'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('찜 해제'));
    await tester.pumpAndSettle();
    expect(find.text('찜한 상품이 없습니다.'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('wishlistProductIds'), isEmpty);
  });
}
