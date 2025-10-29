/// Enhanced Loading Widget Tests
///
/// Widget tests for the enhanced loading widget to ensure
/// proper rendering, animations, and user interactions.
///
/// Test Coverage:
/// - Widget rendering
/// - Animation states
/// - Different loading types
/// - Progress indicators
/// - Custom styling
///
/// Test Cases:
/// - ✅ Circular loading widget
/// - ✅ Linear loading widget
/// - ✅ Pulse loading widget
/// - ✅ Skeleton loading widget
/// - ✅ Bouncing dots loading widget
/// - ✅ Wave loading widget

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/presentation/widgets/enhanced_loading_widget.dart';

void main() {
  group('EnhancedLoadingWidget Tests', () {
    testWidgets('should render circular loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading...',
        size: 32.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should render linear loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.linear,
        message: 'Loading data...',
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('should render pulse loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.pulse,
        message: 'Processing...',
        size: 40.0,
        color: Colors.blue,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.text('Processing...'), findsOneWidget);
    });

    testWidgets('should render skeleton loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.skeleton,
        message: 'Loading content...',
        size: 100.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.text('Loading content...'), findsOneWidget);
    });

    testWidgets('should render shimmer loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.shimmer,
        message: 'Shimmer loading...',
        size: 80.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.text('Shimmer loading...'), findsOneWidget);
    });

    testWidgets('should render bouncing dots loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.bouncingDots,
        message: 'Loading with dots...',
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Loading with dots...'), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(3)); // Three bouncing dots
    });

    testWidgets('should render wave loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.wave,
        message: 'Wave animation loading...',
        size: 32.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Wave animation loading...'), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(5)); // Five wave bars
    });

    testWidgets('should render with custom color', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading with custom color...',
        color: Colors.red,
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      final circularProgress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(circularProgress.valueColor, Colors.red);
    });

    testWidgets('should render with custom animation duration', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading with custom duration...',
        animationDuration: Duration(milliseconds: 500),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading with custom duration...'), findsOneWidget);
    });

    testWidgets('should render with progress bar', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.linear,
        message: 'Loading progress...',
        showProgress: true,
        progress: 0.7,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Loading progress...'), findsOneWidget);

      final linearProgress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(linearProgress.value, 0.7);
    });

    testWidgets('should render without message', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should render with custom padding', (Widget tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading with padding...',
        padding: EdgeInsets.all(32.0),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Padding), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading with padding...'), findsOneWidget);

      final padding = tester.widget<Padding>(
        find.byType(Padding),
      );
      expect(padding.padding, const EdgeInsets.all(32.0));
    });

    testWidgets('should handle empty message gracefully', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: '',
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Should not crash even with empty message
    });

    testWidgets('should handle zero size gracefully', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        size: 0.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Should render without crashing
    });

    testWidgets('should handle very large size gracefully', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        size: 200.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Should render without crashing
    });
  });

  group('ProductSkeletonLoader Tests', () {
    testWidgets('should render product skeleton loader', (WidgetTester tester) async {
      // Arrange
      const widget = ProductSkeletonLoader(itemCount: 3);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Column), findsOneWidget);
      // Should have 3 skeleton items
      expect(find.byType(Padding), findsNWidgets(3));
      // Each item has image placeholder and details
      expect(find.byType(Container), findsNWidgets(6)); // 3 images + 3 details
    });

    testWidgets('should render with default item count', (WidgetTester tester) async {
      // Arrange
      const widget = ProductSkeletonLoader();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Column), findsOneWidget);
      // Should have default 3 skeleton items
      expect(find.byType(Padding), findsNWidgets(3));
    });

    testWidgets('should render with custom item count', (WidgetTester tester) async {
      // Arrange
      const widget = ProductSkeletonLoader(itemCount: 5);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Padding), findsNWidgets(5));
    });

    testWidgets('should render skeleton items with correct structure', (WidgetTester tester) async {
      // Arrange
      const widget = ProductSkeletonLoader(itemCount: 1);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      // Each skeleton item should have:
      // - A Row for layout
      // - Image placeholder (80x80)
      - Details column with multiple text placeholders
      expect(find.byType(Row), findsOneWidget);

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 2); // Image + details

      // Image placeholder
      final imageContainer = row.children[0] as Container;
      final imageConstraints = imageContainer.constraints as BoxConstraints;
      expect(imageConstraints.maxWidth, 80.0);
      expect(imageConstraints.maxHeight, 80.0);

      // Details column
      expect(row.children[1], isA<Column>());
    });
  });

  group('ListSkeletonLoader Tests', () {
    testWidgets('should render list skeleton loader', (WidgetTester tester) async {
      // Arrange
      const widget = ListSkeletonLoader(itemCount: 5);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      // Should have 5 skeleton items
      expect(find.byType(Padding), findsNWidgets(5));
      expect(find.byType(Container), findsNWidgets(5));
    });

    testWidgets('should render with default item count', (WidgetTester tester) async {
      // Arrange
      const widget = ListSkeletonLoader();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      // Should have default 5 skeleton items
      expect(find.byType(Padding), findsNWidgets(5));
    });

    testWidgets('should render with custom item height', (WidgetTester tester) async {
      // Arrange
      const widget = ListSkeletonLoader(itemCount: 3, itemHeight: 80.0);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      // Check if items have correct height
      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final container in containers) {
        final constraints = container.constraints as BoxConstraints?;
        expect(constraints?.maxHeight, 80.0);
      }
    });

    testWidgets('should render skeleton items with correct styling', (WidgetTester tester) async {
      // Arrange
      const widget = ListSkeletonLoader(itemCount: 1);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull);
      expect(decoration!.color, Colors.grey.shade300);
      expect(decoration.borderRadius, isNotNull);
    });
  });

  group('LoadingOverlay Tests', () {
    testWidgets('should not show overlay when not loading', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: false,
        child: Text('Content'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Container), findsNothing); // No overlay container
    });

    testWidgets('should show overlay when loading', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
        loadingType: LoadingType.circular,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget); // Overlay container
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show custom loading message in overlay', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
        message: 'Loading data...',
        loadingType: LoadingType.circular,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should use custom loading widget in overlay', (WidgetTester tester) async {
      // Arrange
      const customLoading = EnhancedLoadingWidget(
        type: LoadingType.bouncingDots,
        message: 'Custom loading...',
      );

      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
        loadingWidget: customLoading,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Custom loading...'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget); // Bouncing dots
    });

    testWidgets('should have semi-transparent background', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.children.length, 2); // Content + overlay

      final overlayContainer = stack.children[1] as Container;
      final decoration = overlayContainer.decoration as BoxDecoration?;
      expect(decoration, isNotNull);

      final color = decoration!.color;
      expect(color.opacity, 0.3); // Semi-transparent
    });

    testWidgets('should center overlay content', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      final stack = tester.widget<Stack>(find.byType(Stack));
      final centerWidget = stack.children[1] as Center;
      expect(centerWidget.child, isA<Card>());
    });
  });

  group('Animation Tests', () {
    testWidgets('should animate circular progress indicator', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Animation should be running (no crash)
    });

    testWidgets('should animate pulse widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.pulse,
        size: 40.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(Container), findsWidgets);
      // Animation should be running (no crash)
    });

    testWidgets('should animate bouncing dots', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.bouncingDots,
        size: 24.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(3));
      // Animation should be running
    });

    testWidgets('should animate wave bars', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.wave,
        size: 32.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(5));
      // Animation should be running
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should have semantic labels for loading widget', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading content...',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Semantics), findsWidgets);
      // Should have semantic label for the loading state
    });

    testWidgets('should announce loading message to screen reader', (WidgetTester tester) async {
      // Arrange
      const widget = EnhancedLoadingWidget(
        type: LoadingType.circular,
        message: 'Loading products...',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('Loading products...'), findsOneWidget);
      // Text widget should be accessible to screen readers
    });

    testWidgets('should have semantic labels for overlay', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingOverlay(
        isLoading: true,
        child: Text('Content'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.byType(Semantics), findsWidgets);
      // Should have semantic labels for the loading overlay
    });
  });
}