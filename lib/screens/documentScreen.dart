import 'package:cmseduc/utils/firebaseData.dart';
import 'package:flutter/material.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:get/route_manager.dart';

class COnfigureResources extends StatefulWidget {
  final String addOrChange;
  final String subject;
  const COnfigureResources(
      {Key? key, required this.addOrChange, required this.subject})
      : super(key: key);

  @override
  _ConfigureResourcesState createState() => _ConfigureResourcesState();
}

class _ConfigureResourcesState extends State<COnfigureResources> {
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

  //   Future<void> loadMaterial(String subject) async {
  //   List documentData = await FirebaseData().materialData(
  //       _resourcesItemMap["Course"],
  //       _resourcesItemMap["Material"],
  //       subject,
  //       int.parse(_resourcesItemMap["Semester"]));

  //   for (var item in documentData) {
  //     _documentsList.add(item["name"]);
  //   }
  //   setState(() {
  //     _isDocumentsLoaded = true;
  //     print(_isDocumentsLoaded);
  //     print(_documentsList);
  //   });
  // }
}
