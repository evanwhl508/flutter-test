import 'package:intl/intl.dart';

class CoinPriceHistory {
  final int timestamp;
  final num price;

  CoinPriceHistory(
      {required this.timestamp,
        required this.price
      });

  factory CoinPriceHistory.fromList(List<dynamic> list) {
    return CoinPriceHistory(
      timestamp: list[0],
      price: list[1],
    );
  }

  String getDatetime() {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(datetime);
  }

}
