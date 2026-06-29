import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_pathfinder/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExcelerateApp());

    // Verify that the app title is present or some basic widget loads.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
