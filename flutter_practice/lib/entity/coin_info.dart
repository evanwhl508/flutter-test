import 'package:flutter_practice/type_define.dart';

class CoinInfo {
  final String id;
  final String url;
  final String name;
  final String symbol;
  final num price;
  final num priceChange1d;
  final num volume;
  final num marketCap;
  final num availableSupply;
  final num totalSupply;

  CoinInfo(
      {required this.id,
        required this.url,
        required this.name,
        required this.symbol,
        required this.price,
        required this.priceChange1d,
        required this.volume,
        required this.marketCap,
        required this.availableSupply,
        required this.totalSupply,
      });

  factory CoinInfo.fromJson(Dict json) {
    return CoinInfo(
      id: json['id'],
      url: json['icon'],
      name: json['name'],
      symbol: json['symbol'],
      price: json['price'],
      priceChange1d: json['priceChange1d'],
      volume: json['volume'],
      marketCap: json['marketCap'],
      availableSupply: json['availableSupply'],
      totalSupply: json['totalSupply'],
    );
  }
}
