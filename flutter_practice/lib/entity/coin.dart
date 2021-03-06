import 'package:flutter_practice/type_define.dart';

class Coin {
  final String id;
  final String url;
  final String name;
  final String symbol;
  final num price;
  final num priceChange1d;
  bool isFav;

  Coin(
      {required this.id,
      required this.url,
      required this.name,
      required this.symbol,
      required this.price,
      required this.priceChange1d,
      required this.isFav});

  factory Coin.fromJson(Dict json) {
    return Coin(
      id: json['id'],
      url: json['icon'],
      name: json['name'],
      symbol: json['symbol'],
      price: json['price'],
      priceChange1d: json['priceChange1d'],
      isFav: false,
    );
  }
}
