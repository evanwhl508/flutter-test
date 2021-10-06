import 'dart:async';
import 'package:flutter_practice/type_define.dart';

extension StreamSubscriptionExt on StreamSubscription {
  void disposedBy(DisposeBag d) {
    d.add(this);
  }
}