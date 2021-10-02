import 'package:flutter/cupertino.dart';
import 'package:flutter_practice/base/base_stateless_widget.dart';
import 'package:provider/provider.dart';

abstract class BaseViewModel extends ChangeNotifier {

}

abstract class BaseMVVMState<T extends StatefulWidget, VM extends BaseViewModel>
    extends BaseState<T> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => buildViewModel(),
        child: Consumer<VM>(
          builder: (ctx, vm, _) => buildChild(ctx, vm),
        )
    );
  }

  VM buildViewModel();

  Widget buildChild(ctx, vm);
}

abstract class BaseMVVMStateless<VM extends BaseViewModel>
    extends BaseStatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => buildViewModel(),
        child: Consumer<VM>(
          builder: (ctx, vm, _) => buildChild(ctx, vm),
        )
    );
  }

  VM buildViewModel();

  Widget buildChild(ctx, vm);
}