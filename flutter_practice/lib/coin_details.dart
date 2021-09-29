import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice/base/base_stateless_widget.dart';
import 'package:flutter_practice/entity/coin_info.dart';
import 'package:http/http.dart' as http;

import 'entity/coin.dart';
import 'entity/coin_exchange.dart';
import 'entity/coin_price_history.dart';

class CoinDetail extends StatefulWidget {
  CoinDetail({Key? key, required this.coin}) : super(key: key);

  final Coin coin;

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends BaseState<CoinDetail> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            // bottom: const TabBar(
            //   tabs: [
            //     Tab(icon: Icon(Icons.directions_car)),
            //     Tab(icon: Icon(Icons.directions_transit)),
            //     Tab(icon: Icon(Icons.directions_bike)),
            //   ],
            // ),
            title: const Text('Coin Detail'),
          ),
          bottomNavigationBar: _coinDetailTabs(),
          body: Column(
            children: [
              Row(
                children: [
                  Image.network(
                    widget.coin.url,
                    width: 50,
                    height: 50,
                    errorBuilder: (ctx, error, trace) {
                      return Container(width: 30, height: 30);
                    },
                  ),
                  Text(widget.coin.name),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      // TODO: pop up a dialog for input amount
                      // buyCoin("test", widget.imgUrl, widget.id, 1.1, widget.price);
                      showTradeDialog(context, widget.coin, "buy");
                    },
                    child: Text('Buy'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      // TODO: pop up a dialog for input amount
                      // TODO: call sell function
                      showTradeDialog(context, widget.coin, "sell");

                    },
                    child: Text('Sell'),
                  ),
                ],
              ),
              Container(
                height: 500,
                child: TabBarView(
                  children: [
                    _coinInfo(widget.coin.id),
                    _coinPriceHistory(widget.coin.id),
                    _coinExchange(widget.coin.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _coinDetailTabs() {
  return Container(
    color: Color(0xFF3F5AA6),
    child: TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.all(5.0),
      indicatorColor: Colors.blue,
      tabs: [
        Tab(icon: Icon(Icons.info_outline)),
        Tab(icon: Icon(Icons.history)),
        Tab(icon: Icon(Icons.monetization_on_outlined)),
      ],
    ),
  );
}

Widget _coinInfo(String coinId) {
  return FutureBuilder(
    future: _fetchCoinInfo(coinId),
    builder: (context, snapshot) {
      // Check for errors
      if (snapshot.hasError) {
        return Container(color: Colors.red,);
      }

      // Once complete, show your application
      if (snapshot.connectionState == ConnectionState.done) {
        CoinInfo coin = snapshot.data as CoinInfo;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("Symbol")),
                Expanded(child: Text(coin.symbol, textAlign: TextAlign.left,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Price")),
                Expanded(child: Text(coin.price.toString(), textAlign: TextAlign.left,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Volume")),
                Expanded(child: Text(coin.volume.toString(), textAlign: TextAlign.start,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Market Cap.")),
                Expanded(child: Text(coin.marketCap.toString(), textAlign: TextAlign.start,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Available Supply")),
                Expanded(child: Text(coin.availableSupply.toString(), textAlign: TextAlign.start,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Total Supply")),
                Expanded(child: Text(coin.totalSupply.toString(), textAlign: TextAlign.start,)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text("Price Change (1d)")),
                Expanded(child: Text(coin.priceChange1d.toString(), textAlign: TextAlign.start,)),
              ],
            ),
          ],
        );
      }

      // Otherwise, show something whilst waiting for initialization to complete
      return Container(color: Colors.white, child: Icon(Icons.more_time),);
    },
  );
}

Widget _coinPriceHistory(String coinId) {
  return FutureBuilder(
    future: _fetchCoinPriceHistory(coinId),
    builder: (context, snapshot) {
      // Check for errors
      if (snapshot.hasError) {
        return Container(color: Colors.red,);
      }

      // Once complete, show your application
      if (snapshot.connectionState == ConnectionState.done) {
        List<CoinPriceHistory> historyList = snapshot.data as List<CoinPriceHistory>;
        return ListView.separated(
            itemBuilder: (ctx, index) {
              CoinPriceHistory history = historyList[index];
              return Row(children: [
                Expanded(child: Text(history.getDatetime().toString())),
                Expanded(child: Text(history.price.toString())),
              ],);
            },
            separatorBuilder: (_, __) => Divider(),
            itemCount: historyList.length);
      }

      // Otherwise, show something whilst waiting for initialization to complete
      return Container(color: Colors.white, child: Icon(Icons.more_time),);
    },
  );
}

Widget _coinExchange(String coinId) {
  return FutureBuilder(
    future: _fetchCoinExchange(coinId),
    builder: (context, snapshot) {
      // Check for errors
      if (snapshot.hasError) {
        return Container(color: Colors.red,);
      }

      // Once complete, show your application
      if (snapshot.connectionState == ConnectionState.done) {
        List<CoinExchange> exchanges = snapshot.data as List<CoinExchange>;
        return ListView.separated(
            itemBuilder: (ctx, index) {
              CoinExchange exchange = exchanges[index];
              return Column(children: [
                Row(children: [
                  Expanded(child: Text(exchange.exchange)),
                  Expanded(child: Text(exchange.price.toString(), textAlign: TextAlign.end,)),
                ],),
                Row(children: [
                  Expanded(child: Text(exchange.pair)),
                  Expanded(child: Text(exchange.pairPrice.toString(), textAlign: TextAlign.start,)),
                  Expanded(child: Text(exchange.volume.toString(), textAlign: TextAlign.end,)),
                ],)
              ],);
            },
            separatorBuilder: (_, __) => Divider(),
            itemCount: exchanges.length);
      }

      // Otherwise, show something whilst waiting for initialization to complete
      return Container(color: Colors.white, child: Icon(Icons.more_time),);
    },
  );
}

showTradeDialog(BuildContext context, Coin coin, String action) {
  TextEditingController _textFieldController = TextEditingController();
  num inputValue = 0;

  AlertDialog dialog = AlertDialog(
    title: Text("$action ${coin.name}"),
    content: TextField(
      onChanged: (value) {
        inputValue = double.parse(value);
      },
      controller: _textFieldController,
      decoration: InputDecoration(hintText: "Amount to $action"),
    ),
    actions: [
      ElevatedButton(
          child: Text("OK"),
          onPressed: () {
            if (action == "buy") {
              buyCoin("test", coin.url, coin.id, inputValue, coin.price);
            }
            else if (action == "sell") {
              sellCoin("test", coin.url, coin.id, inputValue, coin.price);
            }
            Navigator.of(context, rootNavigator: true).pop(true);
          }
      ),
      ElevatedButton(
          child: Text("Cancel"),
          onPressed: () {
            inputValue = 0;
            Navigator.of(context, rootNavigator: true).pop(false);
          }
      ),
    ],
  );

  // Show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      }
  );
}

Future<CoinInfo> _fetchCoinInfo(String coinId) async {
  print("coin id = $coinId");
  final response = await http.get(Uri.parse(
      'https://api.coinstats.app/public/v1/coins/$coinId?currency=USD'));
  if (response.statusCode == 200) {
    CoinInfo coin = CoinInfo.fromJson(jsonDecode(response.body)["coin"]);
    return coin;
  } else {
    throw Exception('Failed to fetch coin info.');
  }
}

Future<List<CoinPriceHistory>> _fetchCoinPriceHistory(String coinId) async {
  print("coin id = $coinId");
  final response = await http.get(Uri.parse(
      'https://api.coinstats.app/public/v1/charts?period=24h&coinId=$coinId'));

  if (response.statusCode == 200) {
    List<CoinPriceHistory> histories = (jsonDecode(response.body)["chart"] as List).map((
        data) => CoinPriceHistory.fromList(data)).toList();
    return histories;
  } else {
    throw Exception('Failed to fetch coin info.');
  }
}

Future<List<CoinExchange>> _fetchCoinExchange(String coinId) async {
  print("coin id = $coinId");
  final response = await http.get(Uri.parse(
      'https://api.coinstats.app/public/v1/markets?coinId=$coinId'));
  if (response.statusCode == 200) {
    List<CoinExchange> exchanges = (jsonDecode(response.body) as List).map((
        data) => CoinExchange.fromJson(data)).toList();
    return exchanges;
  } else {
    throw Exception('Failed to fetch coin info.');
  }
}

Future<void> buyCoin(String username, String imgUrl, String pair, num amount, num price) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('buyCoin');
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
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sellCoin');
  final results = await callable.call(<String, dynamic>{
    'username': username,
    'imgUrl': imgUrl,
    'pair': pair,
    'amount': amount,
    'price': price,
  }).then((value) => {print(value.data)})
      .onError((error, stackTrace) => {print("Error when buy coin")});
}