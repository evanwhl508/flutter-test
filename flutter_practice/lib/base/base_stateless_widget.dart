import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_practice/type_define.dart';


abstract class BaseStatelessWidget extends StatelessWidget {}

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  DisposeBag _disposeBag = [];

  DisposeBag get disposeBag => _disposeBag;

  @override
  void dispose() {
    _disposeBag.forEach((element) {element.cancel();});
    super.dispose();
  }
}