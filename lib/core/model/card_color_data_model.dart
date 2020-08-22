import 'package:flutter/material.dart';

class CardColorData {
  final Color cardColor;
  final Color fontColor;
  final Color progressColor;
  final Color backgroundProgressColor;

  CardColorData(
      {@required this.cardColor,
      @required this.fontColor,
      @required this.progressColor,
      @required this.backgroundProgressColor});
}

class CardColorList {
  List tempList = [];

  List<CardColorData> listCardColorData = [
    CardColorData(
        cardColor: Colors.white,
        fontColor: Colors.black,
        progressColor: Color(0xFFfabb18),
        backgroundProgressColor: Color(0xFFfabb18).withOpacity(0.3)),
    CardColorData(
        cardColor: Colors.black.withOpacity(0.9),
        fontColor: Colors.white,
        progressColor: Colors.white,
        backgroundProgressColor: Colors.white.withOpacity(0.3)),
  ];

  int getIndex(int index) {
    if (tempList.length == 2) tempList = [];

    tempList.add(index);
    return tempList.length - 1;
  }
}
