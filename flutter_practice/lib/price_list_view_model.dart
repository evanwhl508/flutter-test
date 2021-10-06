
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'base/base_view_model.dart';
import 'entity/coin.dart';

class PriceListViewModel extends BaseViewModel {
  List<Coin> rawCoinList = List.empty();
  List<Coin> coinList = List.empty();
  List<String> favCoinList = List.empty();
  var dropdownSubject = BehaviorSubject<String>();
  List<String> items = ["USD", "HKD", "GBP", "JPY"];
  late String dropdownValue;

  void setFavCoin(int index) {
    Coin c = coinList[index];
    c.isFav = !c.isFav;
    handleFavCoin(c);
    notifyListeners();
  }

  void setFavCoinIdsList(List<String> fList) {
    favCoinList = fList;
    if (coinList.isNotEmpty) {
      coinList.forEach((coin) {
        if (favCoinList.contains(coin.id)) {
          coin.isFav = true;
        }
      });
    }
    notifyListeners();
  }

  void setCoinList(List<Coin> cList) {
    coinList = cList;
    rawCoinList = cList;
    notifyListeners();
  }

  void setSearchForm(String searchStr){
    if (searchStr.isEmpty) {
      coinList = rawCoinList;
    } else {
      coinList = rawCoinList
          .where((coin) =>
      coin.name.toLowerCase().contains(searchStr.toLowerCase()) ||
          coin.id.toLowerCase().contains(searchStr.toLowerCase()) ||
          coin.symbol.toLowerCase().contains(searchStr.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void setDropdownValue(String dropdownStr) {
    dropdownSubject.add(dropdownStr);
    dropdownValue = dropdownStr;
    notifyListeners();
  }
}

Future<void> handleFavCoin(Coin coin) {
  CollectionReference favCoinCollection = FirebaseFirestore.instance.collection(
      'users/test/fav_coin');
  Map<String, dynamic> favCoinJson = {
    "id": coin.id,
    "type": "spot"
  };
  if (coin.isFav) {
    return favCoinCollection
        .doc(coin.id)
        .set(favCoinJson, SetOptions(merge: true),)
        .then((value) => print("----- Fav Coin Added"))
        .catchError((error) => print("----- Failed to add fav coin: $error"));
  }
  else {
    return favCoinCollection.where('id', isEqualTo: coin.id).get().then((
        value) {
      favCoinCollection.doc(coin.id).delete()
          .then((value) => print("----- Fav Coin deleted"))
          .catchError((error) => print("----- Failed to delete fav coin: $error"));
    });
  }
}