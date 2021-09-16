import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'base/base_stateless_widget.dart';
import 'my_home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends BaseStatelessWidget {
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Crypto Flutter Version'),
    );
  }

  // @override
  // _AppState createState() => _AppState();
}


// class _AppState extends State<MyApp> {
//   /// The future is part of the state of our widget. We should not call `initializeApp`
//   /// directly inside [build].
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // Initialize FlutterFire:
//       future: _initialization,
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           // return SomethingWentWrong();
//           return Container();
//         }
//
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           return MyHomePage(title: '',);
//         }
//
//         // Otherwise, show something whilst waiting for initialization to complete
//         // return Loading();
//         return Container();
//       },
//     );
//   }
// }
