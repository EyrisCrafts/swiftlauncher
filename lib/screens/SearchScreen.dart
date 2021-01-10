import 'dart:ui';

import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: TextField(
              decoration:
                  InputDecoration(hintText: "  ViewInsets.bottom =  $bottom"))),
    );
  }
}
