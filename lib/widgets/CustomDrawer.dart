import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

var colors = [Colors.pink, Colors.blue, Colors.yellow];

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => Container(
              color: colors[index],
            ));
  }
}
