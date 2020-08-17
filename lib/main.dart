import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'package:uygulama1/Weather.dart';
import 'package:uygulama1/WeatherItem.dart';
import 'package:uygulama1/WeatherData.dart';
import 'package:uygulama1/ForecastData.dart';

//PROJECT'S ROOT
void main() {
  runApp(MaterialApp(
    title: "MCK WeatherApp",
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

//PROJECTS STATE CLASS
class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  Location _location = new Location();
  String error;
  @override
  void initState() {
    super.initState();

    triggerLoadFunction();
  }

  Future<LocationData> getLocationData() async {
    return await _location.getLocation();
  }

  bool isweatherDataLoaded = false;
  triggerLoadFunction() async {
    await loadWeather();
  }

  //BACKGROUND IMAGE
  final Map<String, AssetImage> images = {
    "rain": AssetImage("assets/images/rain.jpg"),
    "clear": AssetImage("assets/images/clear.jpg"),
    "thunderstorm": AssetImage("assets/images/thunderstorm.jpg"),
    "drizzle": AssetImage("assets/images/drizzle.jpg"),
    "snow": AssetImage("assets/images/snow.jpg"),
    "clouds": AssetImage("assets/images/clouds.jpg"),
  };

  // ignore: non_constant_identifier_names
  AssetImage HandleError() {
    if (images.containsKey(weatherData.name)) {
      return images[weatherData.name];
    } else {
      return images["clear"];
    }
  }

  //PROJECT BUILD
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
              child: Column(children: <Widget>[
            //BACKGROUND IMAGE
            Container(
              height: 90.0,
              width: 120.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isweatherDataLoaded //this
                      ? HandleError()
                      : images["clear"],
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.circle,
              ),
            ),

            //WEATHER DATA
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
                            onPressed: () async {
                              await loadWeather();
                            },
                            color: Colors.black,
                          ),
                  ),
                ],
              ),
            ),

            //FUTURE FORECAST WEATHER DATA
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

      isweatherDataLoaded = false;
    });

    //LOCATION PERMISSION CONTROL
    LocationData location;
    try {
      location = await getLocationData();

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please check your location permit!';
      }

      location = null;
    }

    //LOCATION AND WEATHER IMPLEMENT
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

          isweatherDataLoaded = true;
          forecastData =
              new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
          isweatherDataLoaded = true;
        });
      }
    }

    setState(() {
      isLoading = false;

      isweatherDataLoaded = true;
    });
  }
}
