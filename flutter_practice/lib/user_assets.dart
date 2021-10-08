import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice/base/base_view_model.dart';
import 'package:flutter_practice/user_assets_view_model.dart';


class UserAssets extends StatefulWidget {
  UserAssets({Key? key}) : super(key: key);

  @override
  _UserAssetsState createState() => _UserAssetsState();
}

class _UserAssetsState extends BaseMVVMState<UserAssets, UserAssetsViewModel> {

  @override
  void initState() {
    super.initState();
    viewModel.initAssets();
  }

  @override
  UserAssetsViewModel buildViewModel() => UserAssetsViewModel();

  @override
  Widget buildChild(ctx, vm) {
    return Column(
      children: [
        Row(
          children: [
            Text("Current Asset"),
            Checkbox(
              value: vm.hiddenAsset,
              onChanged: (bool? newValue) {
                setState(() {
                  vm.hiddenAsset = newValue!;
                  if (vm.hiddenAsset) {
                    vm.totalAssetsDisplay = "******";
                  } else {
                    vm.totalAssetsDisplay =
                        vm.totalAssets.toStringAsFixed(2);
                  }
                });
              },
            )
          ],
        ),
        Row(
          children: [Text(vm.totalAssetsDisplay)],
        ),
        Row(
          children: [
            Center(
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  vm.firestoreManager.deposit(1000, vm.tether);
                },
                child: Text('Deposit'),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
              itemBuilder: (ctx, index) {
                var asset = vm.assetList[index];
                return Row(
                  children: [
                    Expanded(
                      child: Image.network(
                        asset["imgUrl"],
                        width: 50,
                        height: 50,
                        errorBuilder: (ctx, error, trace) {
                          return Container(width: 30, height: 30);
                        },
                      ),
                    ),
                    Expanded(child: Text(asset["symbol"])),
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            Text(asset["amount"].toString()),
                            Text(vm.assetValueDict[asset["symbol"]]
                                .toStringAsFixed(2)),
                          ],
                        )),
                  ],
                );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: vm.assetList.length),
        ),
      ],
    );
  }
}
