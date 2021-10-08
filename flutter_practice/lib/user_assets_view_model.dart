import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_practice/base/base_view_model.dart';
import 'package:flutter_practice/repo/coin_repo.dart';
import 'package:flutter_practice/type_define.dart';

import 'entity/coin.dart';
import 'firebase/firestore_manager.dart';

class UserAssetsViewModel extends BaseViewModel {
  num totalAssets = 0;
  String totalAssetsDisplay = "0";
  num tether = 0;
  bool hiddenAsset = false;
  Dict assetValueDict = {};
  Dict assetAmountDict = {};
  FirestoreManager firestoreManager = FirestoreManager();
  List assetList = List.empty();

  void initAssets() {
    fetchBalance().listen((event) {
      assetList = event.docs;
      assetList.forEach((element) {
        assetAmountDict[element.data()["symbol"]] = element.data()["amount"];
        assetValueDict[element.data()["symbol"]] = 0;
      });

      fetchCoinList()
          .then((value) => updateAssetsValue(value))
          .then((value) => notifyListeners());
    });
  }

  void updateAssetsValue(List<Coin> coins) {
    totalAssets = 0;
    tether = 0;
    coins.forEach((element) {
      if (assetAmountDict.containsKey(element.id)) {
        totalAssets += assetAmountDict[element.id] * element.price;
        totalAssetsDisplay = totalAssets.toStringAsFixed(2);
        assetValueDict[element.id] =
            assetAmountDict[element.id] * element.price;
      }
      if (element.id == "tether") {
        tether = assetAmountDict[element.id];
      }
    });
  }

  Stream<QuerySnapshot> fetchBalance() {
    return firestoreManager.fetchBalance("test");
  }
  Future<List<Coin>> fetchCoinList() {
    return CoinRepo.fetchCoinList("USD");
  }
}