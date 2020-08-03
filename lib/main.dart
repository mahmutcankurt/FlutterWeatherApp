//IMPORT EDİLEN FLUTTER PAKETLERİ VE KÜTÜPHANELER
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

/*

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

*/

//IMPORT EDİLEN KENDİ OLUŞTURDUĞUM CLASS'LAR
import 'package:uygulama1/Weather.dart';
import 'package:uygulama1/WeatherItem.dart';
import 'package:uygulama1/WeatherData.dart';
import 'package:uygulama1/ForecastData.dart';

//PROJECT'S ROOT
void main() {
  runApp(MaterialApp(
    title: "WeatherApp",
    home: MyApp(),
    
  ));
}

//PROJECTS MAIN CLASS
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
  
}


abstract class MyAppState extends State<MyApp> {
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
  
  // ignore: non_constant_identifier_names
  print(WeatherData);

  Future<LocationData> getLocationData() async {
    return await _location.getLocation();
  }

  final Map<String, AssetImage> images = {
    "rain": AssetImage("assets/images/rain.jpg"),
    "clear": AssetImage("assets/images/clear.jpg"),
  };

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.tealAccent,
          appBar: AppBar(
            title: Text('Flutter Weather App'),
          ),
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            //BACKGROUND IMAGE

            Container(
              decoration: BoxDecoration(
                image: new DecorationImage(
                    image: weatherData == null
                        ? images["clear"]
                        : images[weatherData.name],
                    fit: BoxFit.cover),
              ),
            ),
            //END

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


/*
https://medium.com/@mustafazahidefe/git-notları-5-branch-kavramı-d176626711a4
https://aliozgur.gitbooks.io/git101/content/branching_dallanma_ve_merging_birlestirme/degisiklikleri_merge_etmek.html
https://pub.dev/packages/mapbox_gl
https://account.mapbox.com/access-tokens/ckckgily606gp2srzukfv1an3
http://tphangout.com/flutter-mapbox-and-polylines/
https://github.com/mapbox/flutter-mapbox-gl
https://pub.dev/packages/flutter_map
*/
