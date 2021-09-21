import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/price_list.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

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
          Container(),
          Container(),
        ],
      ),
    );
  }

  Widget _getAssetList() {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchBalance(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

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
          print("data = ${snapshot.data}");
          var res = snapshot.data as QuerySnapshot;
          var assetList = res.docs;
          print("res = ${res}");
          print("docs = ${res.docs}, size = ${res.size}");
          print("docs = ${(res.docs[0]).id}");
          print("docs = ${(res.docs[0]).data()}");
          // Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return ListView.separated(
              itemBuilder: (ctx, index) {
                var asset = assetList[index];
                return Row(children: [
                  Expanded(child: Image.network(
                    asset["imgUrl"],
                    width: 50,
                    height: 50,
                    errorBuilder: (ctx, error, trace) {
                      return Container(width: 30, height: 30);
                    },
                  ),
                  ),
                  Expanded(child: Text(asset["symbol"])),
                  Expanded(child: Column(
                    children: [
                      Text(asset["amount"].toString()),
                      Text("Value"),
                    ],
                  )),
                ],);
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: assetList.length);
        // }

        // return Text("loading");
      },
    );
    return Column(
      children: [
        Row(
          children: [
            Text("Current Asset"),
            Checkbox(value: false, onChanged: (value) {},),
          ],
        ),
        Row(
          children: [
            Text("12345.6789"),
          ],
        ),
        Row(
          children: [
            Center(
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {},
                child: Text('Buy'),
              ),
            ),
          ],
        ),
        // ListView.separated(
        //     itemBuilder: (ctx, index) {
        //       AssetList history = assetList[index];
        //       return Row(children: [
        //         Expanded(child: Text(history.getDatetime().toString())),
        //         Expanded(child: Text(history.price.toString())),
        //       ],);
        //     },
        //     separatorBuilder: (_, __) => Divider(),
        //     itemCount: assetList.length)
      ],
    );
  }
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
  CollectionReference balanceList = FirebaseFirestore.instance.collection('users/test/balance');
// Call the user's CollectionReference to add a new user
  return balanceList.snapshots();
}