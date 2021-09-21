import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'base/base_stateless_widget.dart';
import 'coin_details.dart';
import 'entity/coin.dart';

class PriceList extends StatefulWidget {
  PriceList({Key? key}) : super(key: key);


  @override
  _PriceListState createState() => _PriceListState();
}

class _PriceListState extends BaseState<PriceList> {
  List<Coin> rawCoinList = List.empty();
  List<Coin> coinList = List.empty();
  var dropdownSubject = BehaviorSubject<String>();
  List<String> items = ["USD", "HKD", "GBP", "JPY"];
  String dropdownValue = "USD";

  @override
  void initState() {
    super.initState();
    var timer = Stream.periodic(Duration(seconds: 10), (x) => x);
    dropdownSubject.add("USD");
    CombineLatestStream.combine2(dropdownSubject, timer, (a, b) => a)
        .listen((value) {
      _fetchCoinList(value as String).then((result) {
        print(result);
        if (mounted) {
          setState(() {
            coinList = result;
            rawCoinList = result;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Price List"),
      // ),
      body: _getPriceList(coinList),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Go To Top',
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  Future<List<Coin>> _fetchCoinList(String value) async {
    final response = await http.get(Uri.parse(
        'https://api.coinstats.app/public/v1/coins/?currency=$value&limit=20'));

    if (response.statusCode == 200) {
      List<Coin> res = List.empty();
      List<Coin> coins = (jsonDecode(response.body)["coins"] as List)
          .map((data) => Coin.fromJson(data))
          .toList();
      // List<dynamic> coins = jsonDecode(response.body)["coins"];
      // for (Map<String, dynamic> data in coins) {
      //   res += [Coin.fromJson(data)];
      // }
      return coins;
      // return res;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Widget _getPriceList(List<Coin> coinList) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _getSearchForm()),
            Expanded(child: _getCurrencyDropdown()),
          ],
        ),
        Expanded(child: _getPrice(coinList)),
      ],
    );
  }

  Widget _getPrice(List<Coin> coinList) {
    return ListView.separated(
        itemBuilder: (ctx, index) {
          Coin c = coinList[index];
          return ElevatedButton(
            child: Row(
              children: [
                SizedBox(width: 5),
                Image.network(
                  c.url,
                  width: 50,
                  height: 50,
                  errorBuilder: (ctx, error, trace) {
                    return Container(width: 30, height: 30);
                  },
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      c.symbol,
                      style: new TextStyle(
                        fontSize: 35,
                      ),
                    ),
                    Text(
                      c.id,
                      style: new TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Spacer(flex: 5),
                Column(
                  children: [
                    Text(
                      c.price.toStringAsFixed(2),
                      style: new TextStyle(
                        fontSize: 35,
                      ),
                    ),
                    Text(
                      c.priceChange1d.toStringAsFixed(2) + '%',
                      style: new TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
                Spacer(flex: 1),
                Column(
                  children: [
                    IconButton(
                      icon: new Icon(
                        Icons.favorite,
                        color: (c.isFav ? Colors.red : Colors.grey),
                      ),
                      splashRadius: 25.0,
                      tooltip: 'Set favourite',
                      onPressed: () {
                        setState(() {
                          print("c.isFav = ${c.isFav}");
                          c.isFav = !c.isFav;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_alert),
                      tooltip: 'Set alert',
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CoinDetail(id: c.id, name: c.name, imgUrl: c.url)),
              );
            },
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.black54,
              primary: Colors.white,
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(),
        itemCount: coinList.length);
  }

  Widget _getSearchForm() {
    return TextField(
      decoration: new InputDecoration(
        hintText: 'Search...',
      ),
      onChanged: (String searchStr) {
        setState(() {
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
        });
      },
    );
  }

  Widget _getCurrencyDropdown() {
    return DropdownButton(
      menuMaxHeight: 400,
      value: dropdownValue,
      icon: Icon(Icons.keyboard_arrow_down),
      items: items
          .map((String items) =>
          DropdownMenuItem(value: items, child: Text(items)))
          .toList(),
      // onChanged: (newValue) {setState(() {
      //   this.dropdownValue.add(newValue as String);
      //   // this.test = newValue;
      // });},
      onChanged: (newValue) {
        this.dropdownSubject.add(newValue as String);
        this.dropdownValue = newValue;
      },
    );
  }
}