import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/price_list.dart';
import 'package:intl/intl.dart';

import 'base/base_stateless_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          bottomNavigationBar: _mainTabs(),
          body: _getBody(widget),
          // floatingActionButton: FloatingActionButton(
          // onPressed: () {},
          // tooltip: 'Increment',
          // child: Icon(Icons.arrow_upward),
          // ),
        ),
      ),
    );
  }

  Widget _getBody(Widget w) {
    return Container(
      child: TabBarView(
        children: [
          PriceList(),
          _getAssetList(),
          _getPriceAlertList(),
          _getUserTransactions(),
        ],
      ),
    );
  }

  Widget _getAssetList() {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchBalance(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        // if (snapshot.hasData && !snapshot.data!.exists) {
        //   return Text("Document does not exist");
        // }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        // if (snapshot.connectionState == ConnectionState.done) {
        // print("data = ${snapshot.data}");
        var res = snapshot.data as QuerySnapshot;
        var assetList = res.docs;
        // print("res = ${res}");
        // print("docs = ${res.docs}, size = ${res.size}");
        // print("docs = ${(res.docs[0]).id}");
        // print("docs = ${(res.docs[0]).data()}");
        // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        return ListView.separated(
            itemBuilder: (ctx, index) {
              var asset = assetList[index];
              return Row(
                children: [
                  Expanded(
                    child: Image.network(
                      asset["imgUrl"],
                      width: 50,
                      height: 50,
                      errorBuilder: (ctx, error, trace) {
                        return Container(width: 30, height: 30);
                      },
                    ),
                  ),
                  Expanded(child: Text(asset["symbol"])),
                  Expanded(
                      child: Column(
                    children: [
                      Text(asset["amount"].toString()),
                      Text("Value"),
                    ],
                  )),
                ],
              );
            },
            separatorBuilder: (_, __) => Divider(),
            itemCount: assetList.length);
        // }

        // return Text("loading");
      },
    );
  }
}

Widget _getPriceAlertList() {
  return StreamBuilder<QuerySnapshot>(
    stream: fetchAlertList(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text("Something went wrong");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading");
      }

      // if (snapshot.connectionState == ConnectionState.done) {
      var res = snapshot.data as QuerySnapshot;
      var assetList = res.docs;
      // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
      return ListView.separated(
          itemBuilder: (ctx, index) {
            var asset = assetList[index];
            return Row(
              children: [
                Expanded(
                  child: Text(asset["id"]),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(asset["price"].toString()),
                      Text(asset["direction"]),
                    ],
                  ),
                ),
                Expanded(
                    child: IconButton(
                  icon: const Icon(Icons.cancel),
                  tooltip: 'Delete Alert',
                  onPressed: () {},
                ))
              ],
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: assetList.length);
      // }

      // return Text("loading");
    },
  );
}

Widget _getUserTransactions() {
  return StreamBuilder<QuerySnapshot>(
    stream: fetchTransactions(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text("Something went wrong");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading");
      }

      // if (snapshot.connectionState == ConnectionState.done) {
      var res = snapshot.data as QuerySnapshot;
      var assetList = res.docs;
      // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return ListView.separated(
          itemBuilder: (ctx, index) {
            var asset = assetList[index];
            DateTime datetime = DateTime.fromMillisecondsSinceEpoch(asset["timestamp"]);
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(asset["symbol"]),
                    ),
                    Expanded(
                      child: Text(asset["amount"].toString(), textAlign: TextAlign.end,),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(asset["direction"]),
                    ),
                    Expanded(
                      child: Text(formatter.format(datetime)),
                    ),
                    Expanded(
                      child: Text(asset["price"].toString()),
                    ),
                  ],
                ),
              ],
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: assetList.length);
      // }

      // return Text("loading");
    },
  );
}

Widget _mainTabs() {
  return Container(
    color: Color(0xFF3F5AA6),
    child: TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.all(5.0),
      indicatorColor: Colors.blue,
      tabs: [
        Tab(text: "Price"),
        Tab(text: "Assets"),
        Tab(text: "Alert"),
        Tab(text: "Transactions"),
      ],
    ),
  );
}

Stream<QuerySnapshot> fetchBalance() {
  CollectionReference balanceList =
      FirebaseFirestore.instance.collection('users/test/balance');
// Call the user's CollectionReference to add a new user
  return balanceList.snapshots();
}

Stream<QuerySnapshot> fetchAlertList() {
  CollectionReference alertList =
      FirebaseFirestore.instance.collection('users/test/price_alert');
// Call the user's CollectionReference to add a new user
  return alertList.snapshots();
}

Stream<QuerySnapshot> fetchTransactions() {
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('users/test/transaction');
// Call the user's CollectionReference to add a new user
  return transactions.snapshots();
}