import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice/base/base_stateless_widget.dart';
import 'package:flutter_practice/repo/coin_repo.dart';
import 'package:http/http.dart' as http;

import 'entity/coin.dart';

class UserAssets extends StatefulWidget {
  UserAssets({Key? key}) : super(key: key);

  @override
  _UserAssetsState createState() => _UserAssetsState();
}

class _UserAssetsState extends BaseState<UserAssets> {
  num _totalAssets = 0;
  String _totalAssetsDisplay = "0";
  num _tether = 0;
  bool _hiddenAsset = false;
  Map<String, dynamic> assetValueDict = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchBalance(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> balanceSnapshot) {
        if (balanceSnapshot.hasError) {
          return Text("Something went wrong");
        }

        if (balanceSnapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        var res = balanceSnapshot.data as QuerySnapshot;
        var assetList = res.docs;
        Map<String, dynamic> assetAmountDict = {};
        assetList.forEach((element) {
          assetAmountDict[element.data()["symbol"]] = element.data()["amount"];
          assetValueDict[element.data()["symbol"]] = 0;
        });
        return FutureBuilder(
            future: CoinRepo.fetchCoinList("USD"),
            builder: (context, priceSnapshot) {
              // Check for errors
              if (priceSnapshot.hasError) {
                return Container(
                  color: Colors.red,
                );
              }

              // Once complete, show your application
              if (priceSnapshot.connectionState == ConnectionState.done) {
                var value = priceSnapshot.data as List<Coin>;
                _totalAssets = 0;
                _tether = 0;
                value.forEach((element) {
                  if (assetAmountDict.containsKey(element.id)) {
                    _totalAssets += assetAmountDict[element.id] * element.price;
                    _totalAssetsDisplay = _totalAssets.toStringAsFixed(2);
                    assetValueDict[element.id] =
                        assetAmountDict[element.id] * element.price;
                  }
                  if (element.id == "tether") {
                    _tether = assetAmountDict[element.id];
                  }
                  print(
                      " element = ${element.id}, _totalAssets = $_totalAssets, _tether = $_tether");
                });
                print("_totalAssets = $_totalAssets, _tether = $_tether");

                return Column(
                  children: [
                    Row(
                      children: [
                        Text("Current Asset"),
                        Checkbox(
                          value: _hiddenAsset,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _hiddenAsset = newValue!;
                              if (_hiddenAsset) {
                                _totalAssetsDisplay = "******";
                              } else {
                                _totalAssetsDisplay =
                                    _totalAssets.toStringAsFixed(2);
                              }
                            });
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [Text(_totalAssetsDisplay)],
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
                              deposit(1000, _tether);
                            },
                            child: Text('Deposit'),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.separated(
                          itemBuilder: (ctx, index) {
                            var asset = assetList[index];
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
                                    Text(assetValueDict[asset["symbol"]]
                                        .toStringAsFixed(2)),
                                  ],
                                )),
                              ],
                            );
                          },
                          separatorBuilder: (_, __) => Divider(),
                          itemCount: assetList.length),
                    ),
                  ],
                );
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return Container(color: Colors.white, child: Icon(Icons.more_time),);
            });
      },
    );
  }
}

Stream<QuerySnapshot> fetchBalance() {
  CollectionReference balanceList =
      FirebaseFirestore.instance.collection('users/test/balance');
  return balanceList.snapshots();
}

Future<void> deposit(num initAmount, num adjAmount) {
  DocumentReference tetherDoc =
      FirebaseFirestore.instance.doc('users/test/balance/tether/');
  Map<String, dynamic> tetherJson = {
    "symbol": "tether",
    "amount": initAmount + adjAmount,
    "imgUrl": "https://static.coinstats.app/coins/TetherfopnG.png"
  };
  return tetherDoc
      .set(
        tetherJson,
        SetOptions(merge: true),
      )
      .then((value) => print("----- Fav Coin Added"))
      .catchError((error) => print("----- Failed to add fav coin: $error"));
}
