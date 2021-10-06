import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice/base/base_stateless_widget.dart';
import 'package:flutter_practice/entity/coin_info.dart';
import 'package:flutter_practice/repo/coin_repo.dart';

import 'entity/coin.dart';
import 'entity/coin_exchange.dart';
import 'entity/coin_price_history.dart';
import 'firebase/firebase_functions_manager.dart';

class CoinDetail extends StatefulWidget {
  CoinDetail({Key? key, required this.coin}) : super(key: key);

  final Coin coin;

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends BaseState<CoinDetail> {
  FirebaseFunctionsManager firebaseFunctionsManager = FirebaseFunctionsManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
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
                      showTradeDialog(context, widget.coin, "buy", firebaseFunctionsManager);
                    },
                    child: Text('Buy'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      showTradeDialog(context, widget.coin, "sell", firebaseFunctionsManager);

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
    future: CoinRepo.fetchCoinInfo(coinId),
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
    future: CoinRepo.fetchCoinPriceHistory(coinId),
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
    future: CoinRepo.fetchCoinExchange(coinId),
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

showTradeDialog(BuildContext context, Coin coin, String action, FirebaseFunctionsManager firebaseFunctionsManager) {
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
              firebaseFunctionsManager.buyCoin("test", coin.url, coin.id, inputValue, coin.price);
            }
            else if (action == "sell") {
              firebaseFunctionsManager.sellCoin("test", coin.url, coin.id, inputValue, coin.price);
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