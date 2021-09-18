class CoinExchange {
  final num price;
  final String exchange;
  final String pair;
  final num pairPrice;
  final num volume;

  CoinExchange(
      {required this.price,
        required this.exchange,
        required this.pair,
        required this.pairPrice,
        required this.volume,
      });

  factory CoinExchange.fromJson(Map<String, dynamic> json) {
    return CoinExchange(
      price: json['price'],
      exchange: json['exchange'],
      pair: json['pair'],
      pairPrice: json['pairPrice'],
      volume: json['volume'],
    );
  }
}
