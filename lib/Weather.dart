import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uygulama1/WeatherData.dart';

class Weather extends StatelessWidget {
  final WeatherData weather;

  Weather({Key key, @required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var temperature = (weather.temp - 273.15).round();
    return Column(
      children: <Widget>[
        Text(weather.name, style: new TextStyle(color: Colors.black)),
        Text("\n" + weather.main,
            style: new TextStyle(color: Colors.black, fontSize: 32.0)),
        Text("Temp: " + '${temperature.toString()}°C',
            style: new TextStyle(color: Colors.black)),
        Image.network('https://openweathermap.org/img/w/${weather.icon}.png'),
        Text("Date: " + new DateFormat.yMMMd().format(weather.date),
            style: new TextStyle(color: Colors.black)),
        Text("Hour: " + new DateFormat.Hm().format(weather.date),
            style: new TextStyle(color: Colors.black)),
      ],
    );
  }
}
