import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_practice/entity/coin.dart';
import 'package:flutter_practice/entity/user_price_alert.dart';
import 'package:flutter_practice/type_define.dart';

class FirestoreManager {

  FirestoreManager._privateConstructor();

  static final FirestoreManager _instance = FirestoreManager._privateConstructor();

  factory FirestoreManager() {
    return _instance;
  }

  Stream<QuerySnapshot> fetchFavCoinList(String username) {
    CollectionReference favCoinList =
    FirebaseFirestore.instance.collection('users/$username/fav_coin');
    return favCoinList.snapshots();
  }

  Future<void> addPriceAlert(Coin coin, String price, String direction) {
    CollectionReference alertList = FirebaseFirestore.instance.collection(
        'users/test/price_alert');
    int timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;
    UserPriceAlert pa = UserPriceAlert(
        id: coin.id, price: price, timestamp: timestamp, direction: direction);
    return alertList
        .add(pa.toJson())
        .then((value) => print("Price Alert Added"))
        .catchError((error) => print("Failed to add alert: $error"));
  }

  Future<void> deposit(num initAmount, num adjAmount) {
    DocumentReference tetherDoc =
    FirebaseFirestore.instance.doc('users/test/balance/tether/');
    Dict tetherJson = {
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

  Future<void> handleFavCoin(Coin coin) {
    CollectionReference favCoinCollection = FirebaseFirestore.instance.collection(
        'users/test/fav_coin');
    Dict favCoinJson = {
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

  Stream<QuerySnapshot> fetchBalance(String username) {
    CollectionReference balanceList =
    FirebaseFirestore.instance.collection('users/$username/balance');
// Call the user's CollectionReference to add a new user
    return balanceList.snapshots();
  }

  Stream<QuerySnapshot> fetchAlertList(String username) {
    CollectionReference alertList =
    FirebaseFirestore.instance.collection('users/test/price_alert');
// Call the user's CollectionReference to add a new user
    return alertList.snapshots();
  }

  Stream<QuerySnapshot> fetchTransactions(String username) {
    CollectionReference transactions =
    FirebaseFirestore.instance.collection('users/test/transaction');
// Call the user's CollectionReference to add a new user
    return transactions.snapshots();
  }
}