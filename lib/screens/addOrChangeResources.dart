import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class AddOrChangeResources extends StatefulWidget {
  final String addOrChange;
  final String subject;
  const AddOrChangeResources(
      {Key? key, required this.addOrChange, required this.subject})
      : super(key: key);

  @override
  _AddOrChangeResourcesState createState() => _AddOrChangeResourcesState();
}

class _AddOrChangeResourcesState extends State<AddOrChangeResources> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        title: Text(
          "widget.changeItem",
          style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
