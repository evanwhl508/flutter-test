import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/ext/stream_subscription.dart';
import 'package:flutter_practice/price_list_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'base/base_view_model.dart';
import 'coin_details.dart';
import 'entity/coin.dart';
import 'entity/user_price_alert.dart';

class PriceList extends StatefulWidget {
  PriceList({Key? key}) : super(key: key);


  @override
  _PriceListState createState() => _PriceListState();
}

class _PriceListState extends BaseMVVMState<PriceList, PriceListViewModel> {

  @override
  void initState() {
    super.initState();
    var timer = MergeStream([
      TimerStream(0, Duration(seconds: 0)),
      Stream.periodic(Duration(seconds: 60), (x) => x)
    ]);
    viewModel.setDropdownValue("USD");
    CombineLatestStream.combine2(viewModel.dropdownSubject, timer, (a, b) => a)
        .listen((value) {
          _fetchCoinList(value as String).then((result) {
            _fetchFavCoinList().forEach((element) {
              result.forEach((coin) {
                if (viewModel.favCoinList.contains(coin.id)) {
                  coin.isFav = true;
                }
              });
              viewModel.setCoinList(result);
            }).onError((error, stackTrace) {
                  print("error = $error");
            });
          });
       }).disposedBy(disposeBag);
    _fetchFavCoinList().listen((event) {
      viewModel.setFavCoinIdsList(event.docs.map((e) => e.id).toList());
    }).disposedBy(disposeBag);
  }

  Future<List<Coin>> _fetchCoinList(String value) async {
    final response = await http.get(Uri.parse(
        'https://api.coinstats.app/public/v1/coins/?currency=$value&limit=20'));

    if (response.statusCode == 200) {
      List<Coin> coins = (jsonDecode(response.body)["coins"] as List)
          .map((data) => Coin.fromJson(data))
          .toList();
      return coins;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Widget _getPriceList(PriceListViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _getSearchForm(vm)),
            Expanded(child: _getCurrencyDropdown(vm)),
          ],
        ),
        Expanded(child: _getPrice(vm)),
      ],
    );
  }

  Widget _getPrice(PriceListViewModel vm) {
    return ListView.separated(
        itemBuilder: (ctx, index) {
          Coin c = vm.coinList[index];
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
                        color: getPriceChangeColor(c.priceChange1d),
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
                        vm.setFavCoin(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_alert),
                      tooltip: 'Set alert',
                      onPressed: () {
                        // addPriceAlert(c, "1", "upper");
                        showPriceAlertDialog(context, c);
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
                        CoinDetail(coin: c)),
              );
            },
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.black54,
              primary: Colors.white,
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(),
        itemCount: vm.coinList.length);
  }

  Widget _getSearchForm(PriceListViewModel vm) {
    return TextField(
      decoration: new InputDecoration(
        hintText: 'Search...',
      ),
      onChanged: (String searchStr) {
        vm.setSearchForm(searchStr);
      },
    );
  }

  Widget _getCurrencyDropdown(PriceListViewModel vm) {
    return DropdownButton(
      menuMaxHeight: 400,
      value: vm.dropdownValue,
      icon: Icon(Icons.keyboard_arrow_down),
      items: vm.items
          .map((String items) =>
          DropdownMenuItem(value: items, child: Text(items)))
          .toList(),
      onChanged: (newValue) {
        vm.setDropdownValue(newValue as String);
        // this.dropdownSubject.add(newValue as String);
        // this.dropdownValue = newValue;
      },
    );
  }

  showPriceAlertDialog(BuildContext context, Coin coin) {
    TextEditingController _textFieldController = TextEditingController();
    String inputValue = "0";

    AlertDialog dialog = AlertDialog(
      title: Text("Price Alert to ${coin.name}"),
      content: TextField(
        onChanged: (value) {
          inputValue = value;
        },
        controller: _textFieldController,
        decoration: InputDecoration(hintText: "Alert price of ${coin.name}"),
      ),
      actions: [
        ElevatedButton(
            child: Text("Upper"),
            onPressed: () {
              addPriceAlert(coin, inputValue, "upper");
              Navigator.of(context, rootNavigator: true).pop(true);
            }
        ),
        ElevatedButton(
            child: Text("Lower"),
            onPressed: () {
              addPriceAlert(coin, inputValue, "lower");
              Navigator.of(context, rootNavigator: true).pop(true);
            }
        ),
        ElevatedButton(
            child: Text("Cancel"),
            onPressed: () {
              inputValue = "0";
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

  @override
  Widget buildChild(ctx, vm) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Price List"),
      // ),
      body: _getPriceList(vm),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Go To Top',
        child: Icon(Icons.arrow_upward),
      ),
    );
  }

  @override
  PriceListViewModel buildViewModel() => PriceListViewModel();
}

Future<void> addPriceAlert(Coin coin, String price, String direction) {
  CollectionReference alertList = FirebaseFirestore.instance.collection(
      'users/test/price_alert');
  int timestamp = DateTime
      .now()
      .millisecondsSinceEpoch;
  UserPriceAlert pa = UserPriceAlert(
      id: coin.id, price: price, timestamp: timestamp, direction: direction);
  return alertList
      .add(pa.toJson())
      .then((value) => print("Price Alert Added"))
      .catchError((error) => print("Failed to add alert: $error"));
}

Stream<QuerySnapshot> _fetchFavCoinList() {
  CollectionReference favCoinList =
  FirebaseFirestore.instance.collection('users/test/fav_coin');
  return favCoinList.snapshots();
}

Color getPriceChangeColor(num value) {
  if (value < 0) return Colors.red;
  if (value > 0) return Colors.green;
  return Colors.grey;
}