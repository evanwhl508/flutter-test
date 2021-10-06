import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/price_list.dart';
import 'package:flutter_practice/user_assets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_practice/type_define.dart';

import 'base/base_stateless_widget.dart';
import 'firebase/firestore_manager.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  FirestoreManager firestoreManager = FirestoreManager();

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
        ),
      ),
    );
  }

  Widget _getBody(Widget w) {
    return Container(
      child: TabBarView(
        children: [
          PriceList(),
          UserAssets(),
          _getPriceAlertList(firestoreManager),
          _getUserTransactions(firestoreManager),
        ],
      ),
    );
  }
}

Widget _getPriceAlertList(FirestoreManager firestoreManager) {
  return StreamBuilder<QuerySnapshot>(
    stream: firestoreManager.fetchAlertList("test"),
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

Widget _getUserTransactions(FirestoreManager firestoreManager) {
  return StreamBuilder<QuerySnapshot>(
    stream: firestoreManager.fetchTransactions("test"),
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
                      child: Text(asset["amount"].toStringAsFixed(2), textAlign: TextAlign.end,),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(asset["direction"],
                                  style: new TextStyle(
                                    fontSize: 15,
                                    color: updateTransactionTypeColor(asset["direction"]),
                                  ),
                      ),
                    ),
                    Expanded(
                      child: Text(formatter.format(datetime)),
                    ),
                    Expanded(
                      child: Text(asset["price"].toStringAsFixed(2), textAlign: TextAlign.end,),
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

Color updateTransactionTypeColor(String type) {
  if (type == "buy") return Colors.green;
  if (type == "sell") return Colors.red;
  if (type == "deposit") return Colors.orangeAccent;
  return Colors.grey;

}