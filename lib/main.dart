import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SpaceX Latest Launch App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<dynamic, dynamic> responseMap;
  @override
  void initState() {
    _getThingsOnStartup().then((value){
      print('Async done');
    });
    super.initState();
  }
  Future _getThingsOnStartup() async {
    getStats();
  }

  getStats() async {
    String url = 'https://api.spacexdata.com/v4/launches/latest';
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);
    // this API passes back the id of the new item added to the body
    String body = response.body;

    setState(() {
      responseMap = json.decode(body);
    });
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 125;
    Color colorGreen = Color(0xff08f900);
    FlutterStatusbarcolor.setStatusBarColor(colorGreen);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: colorGreen),),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if(responseMap != null)
            Row(
              children: [
                Image.network(responseMap["links"]["patch"]["small"], width: imageSize, height: imageSize, fit: BoxFit.fitWidth,),
                Expanded(child: Text(responseMap["name"], style: TextStyle(color: colorGreen, fontSize: 26, fontWeight: FontWeight.w300, fontFamily: "monospace"),)),
              ],
            ),
            if(responseMap != null)
            Container(
              margin: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text( "Launch date:\n" +
                                  DateFormat('dd-MM-yyyy').format(DateTime.parse(responseMap["date_utc"])),
                                  style: TextStyle(color: colorGreen, fontSize: 18, fontWeight: FontWeight.w300, fontFamily: "monospace"),
                            ),
                  ),
                  TextButton(
                      onPressed: (){
                        launchURL(responseMap["links"]["wikipedia"]);
                      },
                      child: Image.asset("assets/images/wikipedia-logo.png", width: 40, height: 40,)
                  ),
                  TextButton(
                      onPressed: (){
                        launchURL(responseMap["links"]["webcast"]);
                      },
                      child: Image.asset("assets/images/youtube-logotype.png", width: 40, height: 40,)
                  ),
                  TextButton(
                      onPressed: (){
                        launchURL(responseMap["links"]["article"]);
                      },
                      child: Image.asset("assets/images/information.png", width: 40, height: 40,)
                  ),
                ],
              ),
            ),
            if(responseMap != null)
            Text(responseMap["details"], style: TextStyle(color: colorGreen, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: "monospace"),)

          ],
        ),
      ),
    );
  }

  void launchURL(String url) async => await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
