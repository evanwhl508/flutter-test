
import 'package:cloud_functions/cloud_functions.dart';

class FirebaseFunctionsManager {

  FirebaseFunctionsManager._privateConstructor();

  static final FirebaseFunctionsManager _instance = FirebaseFunctionsManager
      ._privateConstructor();
  FirebaseFunctions _functions = FirebaseFunctions.instance;

  factory FirebaseFunctionsManager() {
    return _instance;
  }

  Future<void> buyCoin(String username, String imgUrl, String pair, num amount, num price) async {
    HttpsCallable callable = _functions.httpsCallable('buyCoin');
    final results = await callable.call(<String, dynamic>{
      'username': username,
      'imgUrl': imgUrl,
      'pair': pair,
      'amount': amount,
      'price': price,
    }).then((value) => {print(value.data)})
        .onError((error, stackTrace) => {print("Error when buy coin")});
  }

  Future<void> sellCoin(String username, String imgUrl, String pair, num amount, num price) async {
    HttpsCallable callable = _functions.httpsCallable('sellCoin');
    final results = await callable.call(<String, dynamic>{
      'username': username,
      'imgUrl': imgUrl,
      'pair': pair,
      'amount': amount,
      'price': price,
    }).then((value) => {print(value.data)})
        .onError((error, stackTrace) => {print("Error when buy coin")});
  }
}