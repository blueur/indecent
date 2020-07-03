// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indecent/widget/dice_widget.dart';

void main() {
  testWidgets('Dice value', (WidgetTester tester) async {
    final int value = Random().nextInt(1024);
    final AsyncSnapshot<int> snapshot =
        AsyncSnapshot.withData(ConnectionState.done, value);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: DiceWidget(
        snapshot: snapshot,
      ),
    ));
    expect(find.text(value.toString()), findsOneWidget);
  });
}
