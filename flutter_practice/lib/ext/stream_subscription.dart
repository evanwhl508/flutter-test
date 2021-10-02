import 'dart:async';
import 'package:flutter_practice/base/base_stateless_widget.dart';

extension StreamSubscriptionExt on StreamSubscription {
  void disposedBy(DisposeBag d) {
    d.add(this);
  }
}