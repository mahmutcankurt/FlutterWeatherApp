import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  var _locality = '';
  var _weather = '';
  

  Future<Position> getPosition() async {
    Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<Placemark> getPlacemark(double latitude, double longitude) async {
    List<Placemark> placemark = await Geolocator()
      .placemarkFromCoordinates(latitude, longitude);
    return placemark[0];
  }

  Future<String> getData(double latitude, double longitude) async {
    String api = 'http://api.openweathermap.org/data/2.5/forecast';
    String appId = 'd89de3f0b2dedfe4f923f1e7f709953a';
    
    String url = '$api?lat=$latitude&lon=$longitude&APPID=$appId';
    
    http.Response response = await http.get(url);

    Map parsed = json.decode(response.body);

    print(parsed);
    
    return (parsed['list'][0]['main']['temp']).toString();
  }

  @override
  void initState() {
    super.initState();
    getPosition().then((position) {
      getPlacemark(position.latitude, position.longitude).then((data) {
        getData(position.latitude, position.longitude).then((weather) {
          setState(() {
            _locality = data.locality;
            _weather = weather;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_locality',
            ),
            Text(
              '$_weather',
            ),
          ],
        ),
      ),
    );
  }
}
