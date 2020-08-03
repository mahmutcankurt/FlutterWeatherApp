
/*

import 'package:flutter/material.dart';
import 'package:uygulama1/WeatherData.dart';




class BackgroundImage extends StatefulWidget{
  @override 
  BackgroundImageWeather createState() => new BackgroundImageWeather();

}
// ignore: must_be_immutable
class BackgroundImageWeather extends State<BackgroundImage>{
  
  final WeatherData weather;

  BackgroundImageWeather({Key key, @required this.weather}) : super(key: key);

  String _backgroundImage;
  String _setImage(){
    String _mTitle = "${weather.main}";

    if(_mTitle == "clear"){
      _backgroundImage = "assets/clear.jpg";
    }
    else if(_mTitle == "rain"){
      _backgroundImage = "assets/rain.jpg";
    }

    print("_mTitle: $_mTitle");
    print("_backgroundImage: $_backgroundImage");
    return _backgroundImage;
  }

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      body: new Container(
        decoration: BoxDecoration(color: Colors.transparent,
        image: new DecorationImage(image: new AssetImage(_setImage())))
      )
    );
  }
}
*/