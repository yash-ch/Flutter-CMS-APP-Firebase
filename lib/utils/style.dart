import 'package:flutter/material.dart';

const LargeTextSize = 26.0;
const MediumTextSize = 20.0;
const SmallTextSize = 16.0;

var lightHighlightedTextStyle =
    TextStyle(color: selectedIconColor, fontSize: 16.0);
var darkHighlightedTextStyle =
    TextStyle(color: selectedIconColor, fontSize: 16.0);

const LightAppBarTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 24.0,
  fontWeight: FontWeight.w700,
);
const DarkAppBarTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 24.0,
  fontWeight: FontWeight.w700,
);

// var selectedIconColor = Color(0xffff8a67); //orange
var selectedIconColor = Color(0xffBB86FC);

Color lightBackgroundColor = Colors.white;
Color darkBackgroundColor = Colors.black;

Color lightIconColor = Colors.black54;
Color darkIconColor = Colors.white60;

Color offWhiteColor = Color(0x0D323232);
Color offBlackColor = Color(0xff323232);

Color darkModeLightTextColor = Colors.white70;
Color lightModeLightTextColor = Colors.black54;

TextStyle darkModeLightTextStyle = TextStyle(
    color: darkModeLightTextColor,
    fontSize: SmallTextSize,
    fontWeight: FontWeight.w500);

TextStyle lightModeLightTextStyle = TextStyle(
    color: lightModeLightTextColor,
    fontSize: SmallTextSize,
    fontWeight: FontWeight.w500);

const LightSettingTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: SmallTextSize,
    fontWeight: FontWeight.w600);
const DarkSettingTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: SmallTextSize,
    fontWeight: FontWeight.w600);

class Style {
  static ThemeData get myLightTheme => ThemeData(
        accentColor: selectedIconColor,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: lightBackgroundColor,
        ),
      );

  static ThemeData get myDarkTheme => ThemeData(
      accentColor: selectedIconColor,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
      ));
}

double getDeviceWidth(context) {
  double deviceWidth = MediaQuery.of(context).size.width;
  return deviceWidth;
}
