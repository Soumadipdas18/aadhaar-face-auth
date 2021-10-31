import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intentapp/op_login.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:  opLogin(),
    );
  }
}



class HomeScreen extends StatefulWidget {
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomeScreen> {
  static const platform = const
  MethodChannel('going.native.for.userdata');
  String _username = 'Data received: No data';
  String _userId = '1111';

  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 100.0),
        child: Align(
          alignment: Alignment(0, 0),
          child: Column(
            children: <Widget>[
              Container(margin: EdgeInsets.only(top: 20.0)),
              _textView('Flutter app '),
              Container(margin: EdgeInsets.only(top: 80.0)),
              _textView('User ID: $_userId'),
              Container(margin: EdgeInsets.only(top: 20.0)),
              _textView(_username),
              Container(margin: EdgeInsets.only(top: 20.0)),
              RaisedButton(
                child: Text('Launch App2'),
                onPressed: launchApp2,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textView(String text) {
    return Text(text,textScaleFactor: 1.3,);
  }

  Future<void> launchApp2() async {
    String username;
    try {
      final result = await platform.invokeMethod('launchApp2',<String, String> { 'ekyc': "mov" });
      username = 'Data received: $result';
    } on PlatformException catch (e) {
      username = 'Data received: No data';
    }


    setState(() {
      _username = username;
    });
  }
}