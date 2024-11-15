import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_1/pages/board_output_page.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('BoardOutputPage Widget Tests', () {
    testWidgets('应该显示正确的标题', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => BoardConfigNotifier(),
          child: MaterialApp(
            home: BoardOutputPage(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('输出配置'), findsOneWidget);
    });

    testWidgets('按下浮动按钮时应该添加新板子', (WidgetTester tester) async {
      // Arrange
      final boardNotifier = BoardConfigNotifier();
      await tester.pumpWidget(
        ChangeNotifierProvider<BoardConfigNotifier>.value(
          value: boardNotifier,
          child: MaterialApp(
            home: BoardOutputPage(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.length, 1);
      expect(find.text('板子 0 输出配置'), findsOneWidget);

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.length, 2);
      expect(find.text('板子 0 输出配置'), findsOneWidget);
      expect(find.text('板子 1 输出配置'), findsOneWidget);
    });

    testWidgets('按下删除按钮时应该删除板子', (WidgetTester tester) async {
      // Arrange
      final boardNotifier = BoardConfigNotifier();
      await tester.pumpWidget(
        ChangeNotifierProvider<BoardConfigNotifier>.value(
          value: boardNotifier,
          child: MaterialApp(
            home: BoardOutputPage(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('板子 0 输出配置'),
            matching: find.byType(Row),
          ),
          matching: find.byIcon(Icons.delete),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.length, 1);
      expect(find.text('板子 0 输出配置'), findsNothing);
      expect(find.text('板子 1 输出配置'), findsOneWidget);

      // Act
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('板子 1 输出配置'),
            matching: find.byType(Row),
          ),
          matching: find.byIcon(Icons.delete),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.length, 0);
      expect(find.text('板子 0 输出配置'), findsNothing);
    });

    testWidgets('按下添加按钮时应该添加输出通道行',
        (WidgetTester tester) async {
      // Arrange
      final boardNotifier = BoardConfigNotifier();
      await tester.pumpWidget(
        ChangeNotifierProvider<BoardConfigNotifier>.value(
          value: boardNotifier,
          child: MaterialApp(
            home: BoardOutputPage(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.first.outputs.length, 1);
    });

    testWidgets('按下删除按钮时应该删除输出通道',
        (WidgetTester tester) async {
      // Arrange
      final boardNotifier = BoardConfigNotifier();
      await tester.pumpWidget(
        ChangeNotifierProvider<BoardConfigNotifier>.value(
          value: boardNotifier,
          child: MaterialApp(
            home: BoardOutputPage(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pumpAndSettle();

      // Assert
      expect(boardNotifier.allBoard.isEmpty, true);
    });
  });
}
