import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final AsyncSnapshot<int> snapshot;

  const DiceWidget({
    Key key,
    @required this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = snapshot.connectionState == ConnectionState.done
        ? Colors.black
        : Colors.grey;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      child: SizedBox.fromSize(
        size: Size.square(64.0),
        child: Center(
          child: Text(
            snapshot.hasData ? snapshot.data.toString() : '?',
            style: TextStyle(
              fontSize: 32.0,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
