import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  final int initialValue;

  const CounterWidget(this.initialValue);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _counter++;
            });
          },
          icon: Icon(Icons.add),
        ),
        Text('$_counter'),
        IconButton(
          onPressed: () {
            if (_counter > 1) {
              setState(() {
                _counter--;
              });
            }
          },
          icon: Icon(Icons.remove),
        ),
      ],
    );
  }
}
