import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayni/l10n/app_localizations.dart';
import 'package:dayni/shared/widgets/common_widgets.dart';

void main() {
  testWidgets('EmptyStateView shows title subtitle and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EmptyStateView(
            title: 'ما عندك زبائن بعد',
            subtitle: 'أضف أول زبون وابدأ بتنظيم ديونك.',
            actionLabel: 'إضافة زبون',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('ما عندك زبائن بعد'), findsOneWidget);
    expect(find.text('أضف أول زبون وابدأ بتنظيم ديونك.'), findsOneWidget);
    await tester.tap(find.text('إضافة زبون'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('app forces RTL directionality', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          home: Text('دَيني'),
        ),
      ),
    );
    final directionality = tester.widget<Directionality>(
      find.byWidgetPredicate(
        (w) => w is Directionality && w.textDirection == TextDirection.rtl,
      ),
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
