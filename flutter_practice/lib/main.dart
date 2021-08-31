import 'package:flutter/material.dart';

import 'base/base_stateless_widget.dart';
import 'my_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends BaseStatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Crypto Flutter Version'),
    );
  }
}

