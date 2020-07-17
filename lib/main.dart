import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';


import 'package:uygulama1/Weather.dart';
import 'package:uygulama1/WeatherItem.dart';
import 'package:uygulama1/WeatherData.dart';
import 'package:uygulama1/ForecastData.dart';

void main() {
  runApp(MaterialApp(
    title: "WeatherApp",
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  Location _location = new Location();
  String error;

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  Future<LocationData> getLocationData() async {
    return await _location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.lightBlue[100],
          appBar: AppBar(
            title: Text('Flutter Weather App'),
          ),
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: weatherData != null
                        ? Weather(weather: weatherData)
                        : Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                new AlwaysStoppedAnimation(Colors.black),
                          )
                        : IconButton(
                            icon: new Icon(Icons.refresh),
                            tooltip: 'Refresh',
                            onPressed: loadWeather,
                            color: Colors.black,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        child: Text("Open Route"),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SecondRoute()))),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200.0,
                  child: forecastData != null
                      ? ListView.builder(
                          itemCount: forecastData.list.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => WeatherItem(
                              weather: forecastData.list.elementAt(index)))
                      : Container(),
                ),
              ),
            )
          ]))),
    );
  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    LocationData location;
    try {
      location = await getLocationData();

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    if (location != null) {
      final lat = location.latitude;
      final lon = location.longitude;

      final weatherResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/weather?APPID=d89de3f0b2dedfe4f923f1e7f709953a&lat=${lat.toString()}&lon=${lon.toString()}');
      final forecastResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/forecast?APPID=d89de3f0b2dedfe4f923f1e7f709953a&lat=${lat.toString()}&lon=${lon.toString()}');

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        return setState(() {
          weatherData =
              new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          forecastData =
              new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FlutterMap(
      options: new MapOptions(
        center: new LatLng(51.5, -0.09),
        zoom: 13.0,
      ),
      layers: [
        new TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mahmutcankurt/ckckgily606gp2srzukfv1an3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWFobXV0Y2Fua3VydCIsImEiOiJja2NrZ2lseTYwNmdwMnNyenVrZnYxYW4zIn0.KDcHWGT3kj16csFFJF5TiA",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoibWFobXV0Y2Fua3VydCIsImEiOiJja2NrZ2lseTYwNmdwMnNyenVrZnYxYW4zIn0.KDcHWGT3kj16csFFJF5TiA',
              'id': 'mapbox.mapbox-streets-v7'
            }),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 80.0,
              height: 80.0,
              point: new LatLng(51.5, -0.09),
              builder: (context) => new Container(
                          child: RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              print('Marker tapped');
                            },
                          ),),
            ),
          ],
        ),
      ],
    );
  }
}

/*
https://medium.com/@mustafazahidefe/git-notları-5-branch-kavramı-d176626711a4
https://aliozgur.gitbooks.io/git101/content/branching_dallanma_ve_merging_birlestirme/degisiklikleri_merge_etmek.html
https://pub.dev/packages/mapbox_gl
https://account.mapbox.com/access-tokens/ckckgily606gp2srzukfv1an3
http://tphangout.com/flutter-mapbox-and-polylines/
https://github.com/mapbox/flutter-mapbox-gl
https://pub.dev/packages/flutter_map
*/
