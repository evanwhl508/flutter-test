import 'package:flutter_practice/type_define.dart';

class UserPriceAlert {
  final String id;
  final String price;
  final String direction;
  final num timestamp;

  UserPriceAlert(
      {required this.id,
        required this.price,
        required this.timestamp,
        required this.direction,
      });

  Dict toJson() => {
    'id': id,
    'price': price,
    'timestamp': timestamp,
    'direction': direction,
  };
}
