// test/widget/movie_search_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviemaster/presentation/widgets/search_bar.dart';

void main() {
  group('MovieSearchBar Widget Tests', () {
    testWidgets('should call onSearch with debounce of 500ms', (WidgetTester tester) async {
      // Arrange
      String? searchedQuery;
      int callCount = 0;
      final onSearch = (String query) {
        searchedQuery = query;
        callCount++;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieSearchBar(onSearch: onSearch),
          ),
        ),
      );

      // Act - вводимо текст, але чекаємо менше за debounce
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 400)); // Менше за 500ms

      // Assert - ще не повинно бути виклику
      expect(searchedQuery, isNull);
      expect(callCount, 0);

      // Act - чекаємо решту часу
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Assert - тепер повинен бути виклик
      expect(searchedQuery, 'test');
      expect(callCount, 1);
    });

    testWidgets('should clear search and call onSearch with empty string when clear button is pressed',
            (WidgetTester tester) async {
          // Arrange
          String? searchedQuery;
          final onSearch = (String query) {
            searchedQuery = query;
          };

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MovieSearchBar(onSearch: onSearch),
              ),
            ),
          );

          // Act - вводимо текст і чекаємо debounce
          await tester.enterText(find.byType(TextField), 'test');
          await tester.pumpAndSettle(const Duration(milliseconds: 600));

          // Clear button повинен з'явитися
          expect(find.byIcon(Icons.clear), findsOneWidget);

          // Act - натискаємо clear
          await tester.tap(find.byIcon(Icons.clear));
          await tester.pumpAndSettle(const Duration(milliseconds: 600));

          // Assert
          expect(searchedQuery, ''); // onSearch повинен викликатися з пустим рядком
          expect(find.text('test'), findsNothing); // Текст має зникнути
          expect(find.byIcon(Icons.clear), findsNothing); // Кнопка clear має зникнути
        });

    testWidgets('should show and hide clear button based on text presence',
            (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MovieSearchBar(onSearch: (_) {}),
              ),
            ),
          );

          // Initially no clear button
          expect(find.byIcon(Icons.clear), findsNothing);

          // Type text - clear button should appear
          await tester.enterText(find.byType(TextField), 't');
          await tester.pump();
          expect(find.byIcon(Icons.clear), findsOneWidget);

          // Clear text - clear button should disappear
          await tester.tap(find.byIcon(Icons.clear));
          await tester.pump();
          expect(find.byIcon(Icons.clear), findsNothing);
        });

    testWidgets('should have correct UI elements', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieSearchBar(onSearch: (_) {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget); // Prefix icon
      expect(find.text('Пошук фільмів...'), findsOneWidget); // Hint text
      expect(find.byType(Padding), findsOneWidget); // Padding around
    });

    testWidgets('should cancel previous timer when typing fast', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      List<String> allQueries = [];
      final onSearch = (String query) {
        callCount++;
        allQueries.add(query);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieSearchBar(onSearch: onSearch),
          ),
        ),
      );

      // Act - швидкий набір з паузами менше 500ms
      await tester.enterText(find.byType(TextField), 't');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'te');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'tes');
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Assert - тільки один виклик з останнім значенням
      expect(callCount, 1);
      expect(allQueries, ['test']);
    });

    testWidgets('should dispose timer and controller properly', (WidgetTester tester) async {
      // Arrange
      final onSearch = (String _) {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieSearchBar(onSearch: onSearch),
          ),
        ),
      );

      // Act - вводимо текст, потім замінюємо widget
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Dispose widget (замінюємо на інший)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(), // Пустий widget
          ),
        ),
      );

      // Assert - не повинно бути помилок при dispose
      // Якщо тест не падає - все добре
      expect(true, true);
    });
  });
}