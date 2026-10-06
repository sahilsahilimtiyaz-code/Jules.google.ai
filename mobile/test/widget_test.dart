import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jules/main.dart';
import 'package:jules/services/agent_state.dart';
import 'package:jules/services/theme_state.dart';

void main() {
  testWidgets('app boots to splash then home', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AgentState()),
          ChangeNotifierProvider(create: (_) => ThemeState()),
        ],
        child: const JulesApp(),
      ),
    );
    expect(find.text('jules'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(PageView), findsOneWidget);
  });
}
