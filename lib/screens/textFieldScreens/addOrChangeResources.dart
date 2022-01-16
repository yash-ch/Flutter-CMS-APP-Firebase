import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class AddOrChangeResources extends StatefulWidget {
  final String addOrChange;
  final String course;
  final String subject;
  final String materialType;
  final int semester;
  final String changeMaterial;
  const AddOrChangeResources(
      {Key? key,
      required this.addOrChange,
      required this.subject,
      required this.course,
      required this.materialType,
      required this.semester,
      required this.changeMaterial})
      : super(key: key);

  @override
  _AddOrChangeResourceState createState() => _AddOrChangeResourceState();
}

class _AddOrChangeResourceState extends State<AddOrChangeResources> {
  final TextEditingController _titleOfTheMaterial = TextEditingController();
  final TextEditingController _linkOfTheMaterial = TextEditingController();

  @override
  void initState() {
    _prefillTextField();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        title: Text(
          widget.subject,
          style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: addOrChangeCourseWidget(),
    );
  }

  Widget addOrChangeCourseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // lightTextWidget(
        //     "Name of the ${(widget.materialType).substring(0, (widget.materialType).length - 1)}"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: TextField(
            controller: _titleOfTheMaterial,
            decoration: InputDecoration(
              labelText:
                  "Enter ${(widget.materialType).substring(0, (widget.materialType).length - 1)} Name",
            ),
          ),
        ),
        // lightTextWidget("Link"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: TextField(
            controller: _linkOfTheMaterial,
            decoration: InputDecoration(
              labelText:
                  "Enter ${(widget.materialType).substring(0, (widget.materialType).length - 1)} Google Drive Link",
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: selectedIconColor),
                onPressed: () {
                  if (_titleOfTheMaterial.text.trim() != "" ||
                      _linkOfTheMaterial.text.trim() != "") {
                    FirebaseData().materialData(
                        context,
                        widget.addOrChange,
                        widget.changeMaterial,
                        widget.course,
                        widget.materialType,
                        widget.subject,
                        widget.semester,
                        _titleOfTheMaterial.text.trim(),
                        _linkOfTheMaterial.text.trim());
                  } else {
                    Fluttertoast.showToast(
                        msg: "Material name and email can't be left blank.",
                        toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: widget.addOrChange == "Change"
                    ? Text("UPDATE")
                    : Text("UPLOAD")),
          ),
        ),
        widget.addOrChange == "Change"
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        showMaterialResponsiveDialog(
                            context: context,
                            title: "Are you sure?",
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: RichText(
                                        text: TextSpan(
                                            children: <TextSpan>[
                                          TextSpan(
                                              text: widget.course,
                                              style: TextStyle(
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: SmallTextSize))
                                        ],
                                            text: "Course : ",
                                            style: TextStyle(
                                                color: selectedIconColor,
                                                fontSize: SmallTextSize))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: RichText(
                                        text: TextSpan(
                                            children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  (widget.semester).toString(),
                                              style: TextStyle(
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: SmallTextSize))
                                        ],
                                            text: "Semester : ",
                                            style: TextStyle(
                                                color: selectedIconColor,
                                                fontSize: SmallTextSize))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: RichText(
                                      text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: widget.materialType,
                                                style: TextStyle(
                                                    color: Get.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: SmallTextSize))
                                          ],
                                          text: "Material Type : ",
                                          style: TextStyle(
                                              color: selectedIconColor,
                                              fontSize: SmallTextSize)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: RichText(
                                        text: TextSpan(
                                            children: <TextSpan>[
                                          TextSpan(
                                              text: widget.subject,
                                              style: TextStyle(
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: SmallTextSize))
                                        ],
                                            text: "Subject : ",
                                            style: TextStyle(
                                                color: selectedIconColor,
                                                fontSize: SmallTextSize))),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      "Are you sure you want to delete \"${widget.changeMaterial}\"? You won't be able to restore it.",
                                      style: TextStyle(fontSize: SmallTextSize),
                                    ),
                                  ),

                                  // Text(widget.changeMaterial),
                                ],
                              ),
                            ),
                            maxLongSide: 340,
                            onConfirmed: () {
                              FirebaseData().materialData(
                                  context,
                                  "Delete",
                                  widget.changeMaterial,
                                  widget.course,
                                  widget.materialType,
                                  widget.subject,
                                  widget.semester,
                                  "",
                                  "");
                            });
                      },
                      style:
                          ElevatedButton.styleFrom(primary: selectedIconColor),
                      child: Text("DELETE")),
                ),
              )
            : Offstage()
      ],
    );
  }

  Future<void> _prefillTextField() async {
    try {
      if (widget.addOrChange == "Change") {
        List materialMap = await FirebaseData().materialData(
            context,
            "none",
            "none",
            widget.course,
            widget.materialType,
            widget.subject,
            widget.semester,
            "none",
            "none");

        for (var material in materialMap) {
          if (material["name"] == widget.changeMaterial) {
            _titleOfTheMaterial.text = material["name"];
            _linkOfTheMaterial.text = material["link"];
          }
        }
      }
    } catch (e) {}
  }
}
