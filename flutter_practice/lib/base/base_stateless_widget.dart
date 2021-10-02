import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef DisposeBag = List<StreamSubscription>;

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