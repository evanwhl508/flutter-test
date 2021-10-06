import 'dart:convert';

import 'package:flutter_practice/entity/coin_exchange.dart';
import 'package:flutter_practice/entity/coin_info.dart';
import 'package:flutter_practice/entity/coin_price_history.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_practice/entity/coin.dart';

class CoinRepo {
  CoinRepo();

  static Future<List<Coin>> fetchCoinList(String value) async {
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
  static Future<CoinInfo> fetchCoinInfo(String coinId) async {
    // print("coin id = $coinId");
    final response = await http.get(Uri.parse(
        'https://api.coinstats.app/public/v1/coins/$coinId?currency=USD'));
    if (response.statusCode == 200) {
      CoinInfo coin = CoinInfo.fromJson(jsonDecode(response.body)["coin"]);
      return coin;
    } else {
      throw Exception('Failed to fetch coin info.');
    }
  }

  static Future<List<CoinPriceHistory>> fetchCoinPriceHistory(String coinId) async {
    // print("coin id = $coinId");
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

  static Future<List<CoinExchange>> fetchCoinExchange(String coinId) async {
    // print("coin id = $coinId");
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
}