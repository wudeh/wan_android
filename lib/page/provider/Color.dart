import 'package:flutter/material.dart';

class Color with ChangeNotifier {
  List colorList = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.grey,
  ];
  var colorMain = Colors.blue;
  // 改变主题颜色
   void changeColor(color){
     colorMain = color;
     notifyListeners();
   }
}