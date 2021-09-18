import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'base/base_stateless_widget.dart';
import 'coin_details.dart';
import 'entity/coin.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  List<Coin> coinList = List.empty();

  @override
  void initState() {
    super.initState();
    _fetchCoinList().then((result) {
      print(result);
      setState(() {
        coinList = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          child: Center(
            child: _getBody(coinList),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  Future<List<Coin>> _fetchCoinList() async {
    final response = await http.get(Uri.parse(
        'https://api.coinstats.app/public/v1/coins/?currency=USD&limit=20'));

    if (response.statusCode == 200) {
      List<Coin> res = List.empty();
      List<Coin> coins = (jsonDecode(response.body)["coins"] as List).map((
          data) => Coin.fromJson(data)).toList();
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

  Widget _getBody(List<Coin> coinList) {
    return ListView.separated(
        itemBuilder: (ctx, index) {
          Coin c = coinList[index];
          return ElevatedButton(
            child: Row(
              children: [
                SizedBox(width: 5),
                Image.network(c.url, width: 50, height: 50,
                  errorBuilder: (ctx, error, trace) {
                    return Container(width: 30, height: 30);
                  },),
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
                MaterialPageRoute(builder: (context) => CoinDetail(id: c.id, name: c.name, imgUrl:c.url)),
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
}
