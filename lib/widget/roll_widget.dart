import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'dice_widget.dart';

class RollWidget extends StatefulWidget {
  final int diceCount;
  final int diceValue;
  final List<int> diceFaces;

  RollWidget({
    Key key,
    @required this.diceCount,
    @required this.diceValue,
    @required this.diceFaces,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    debugPrint(diceFaces.map((dice) => dice.toString()).join('+'));
    return _RollState(
      diceCount,
      diceValue,
      diceFaces,
    );
  }
}

class _RollState extends State<RollWidget> {
  static Random _random = Random();
  final int diceCount;
  final int diceValue;
  final List<int> diceFaces;
  List<Stream<int>> _diceValues;
  Stream<int> _resultValues;

  _RollState(
    this.diceCount,
    this.diceValue,
    this.diceFaces,
  )   : this._diceValues = List.filled(diceFaces.length, Stream.empty()),
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Center(
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
                  ),
                ),
              ),
            ),
            const Text(
              '=',
              style: TextStyle(fontSize: 64),
            ),
            StreamBuilder<int>(
              stream: _resultValues,
              builder: (context, snapshot) => Text(
                snapshot.hasData ? snapshot.data.toString() : '?',
                style: TextStyle(
                  color: snapshot.connectionState == ConnectionState.done
                      ? Colors.black
                      : Colors.grey,
                  fontSize: 64,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () => edit(context),
              child: const Icon(Icons.edit),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _resetStreams();
                });
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<String> edit(BuildContext context) async {
    final TextEditingController countController = TextEditingController(
      text: this.diceCount.toString(),
    );
    final TextEditingController valueController = TextEditingController(
      text: this.diceValue.toString(),
    );
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: countController,
                decoration: const InputDecoration(
                  labelText: 'Number of dices',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Dice value',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () {
                final String count = countController.value.text;
                final String value = valueController.value.text;
                if (count.isNotEmpty && value.isNotEmpty) {
                  final String path = '/roll/${count}d${value}';
                  Navigator.pushNamed(context, path);
                }
              },
            )
          ],
        );
      },
    );
  }
}
