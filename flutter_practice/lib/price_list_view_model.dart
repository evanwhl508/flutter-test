import 'package:rxdart/rxdart.dart';

import 'base/base_view_model.dart';
import 'entity/coin.dart';
import 'firebase/firestore_manager.dart';

class PriceListViewModel extends BaseViewModel {
  List<Coin> rawCoinList = List.empty();
  List<Coin> coinList = List.empty();
  List<String> favCoinList = List.empty();
  var dropdownSubject = BehaviorSubject<String>();
  List<String> items = ["USD", "HKD", "GBP", "JPY"];
  late String dropdownValue;
  FirestoreManager firestoreManager = FirestoreManager();

  void updateFavCoin(int index) {
    Coin c = coinList[index];
    c.isFav = !c.isFav;
    firestoreManager.handleFavCoin(c);
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