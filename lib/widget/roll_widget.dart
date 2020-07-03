import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'dice_widget.dart';

class RollWidget extends StatefulWidget {
  final List<int> diceFaces;

  RollWidget({
    Key key,
    @required this.diceFaces,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    debugPrint(diceFaces.map((dice) => dice.toString()).join('+'));
    return _RollState(diceFaces);
  }
}

class _RollState extends State<RollWidget> {
  static Random _random = Random();
  final List<int> diceFaces;
  List<Stream<int>> _diceValues;
  Stream<int> _resultValues;

  _RollState(this.diceFaces)
      : this._diceValues = List.filled(diceFaces.length, Stream.empty()),
        this._resultValues = Stream.empty();

  static Stream<int> _getValues(int value, int maxCount, int maxDelay) async* {
    final count = _random.nextInt(maxCount) + 1;
    for (var i = 1; i <= count; i++) {
      await Future.delayed(Duration(
        milliseconds: _random.nextInt((maxDelay * i / count).round()),
      ));
      yield _random.nextInt(value) + 1;
    }
  }

  void _resetStreams() {
    _diceValues = diceFaces
        .map((face) => _getValues(face, 16, 256))
        .map((stream) => stream.asBroadcastStream())
        .toList();
    _resultValues = CombineLatestStream.list(_diceValues)
        .map((values) => values.reduce((a, b) => a + b));
  }

  @override
  void initState() {
    super.initState();
    _resetStreams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: _diceValues
                        .map((stream) => StreamBuilder<int>(
                              stream: stream,
                              builder: (context, snapshot) => DiceWidget(
                                snapshot: snapshot,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Icon(
                  Icons.arrow_downward,
                  size: 64.0,
                ),
                StreamBuilder<int>(
                  stream: _resultValues,
                  builder: (context, snapshot) => Text(
                    snapshot.hasData ? snapshot.data.toString() : '?',
                    style: TextStyle(
                      color: snapshot.connectionState == ConnectionState.done
                          ? Colors.black
                          : Colors.grey,
                      fontSize: 64.0,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 64.0,
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _resetStreams();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
