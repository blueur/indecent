import 'package:flutter/material.dart';
import 'package:indecent/widget/roll_widget.dart';

final String rollPath = '/roll';

void main() {
  final List<_Route> routes = [
    _Route(
      regExp: new RegExp(rollPath + r'/([1-9]\d*)d([1-9]\d*)$'),
      onMatch: (match) {
        final int diceCount = int.parse(match.group(1));
        final int diceValue = int.parse(match.group(2));
        return RollWidget(
          diceFaces: List.filled(diceCount, diceValue),
        );
      },
    ),
  ];

  runApp(MaterialApp(
    title: 'Indecent',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    onGenerateRoute: (settings) {
      final Widget widget =
          routes.map((route) => route.test(settings)).firstWhere(
                (widget) => widget != null,
                orElse: () => null,
              );
      if (widget != null) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => widget,
        );
      } else {
        return MaterialPageRoute(
          settings: settings.copyWith(name: rollPath + '/1d100'),
          builder: (context) => RollWidget(
            diceFaces: [100],
          ),
        );
      }
    },
  ));
}

class _Route {
  final RegExp regExp;
  final Widget Function(RegExpMatch match) onMatch;

  _Route({this.regExp, this.onMatch});

  Widget test(RouteSettings settings) {
    final match = regExp.firstMatch(settings.name);
    if (match != null) {
      return onMatch(match);
    } else {
      return null;
    }
  }
}
