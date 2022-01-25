import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;

class AddOrChangeResources extends StatefulWidget {
  //for resources and AECC and GE
  final String whichScreen;
  final String addOrChange;
  final String course;
  final String subject;
  final String materialType;
  final int semester;
  final String changeMaterial;
  const AddOrChangeResources(
      {Key? key,
      required this.whichScreen,
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
          (widget.addOrChange == "Add" ? "Add " : "Change ") +
              widget.materialType
                  .toString()
                  .substring(0, widget.materialType.toString().length - 1),
          style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: addOrChangeResourceWidget(),
    );
  }

  Widget addOrChangeResourceWidget() {
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
        Container(
            width: double.maxFinite,
            height: 10.0,
            child: Text("- - - - " * 15)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: selectedIconColor),
                onPressed: () {
                  _updatedOrUploadResources();
                },
                child: widget.addOrChange == "Change"
                    ? Text("UPDATE")
                    : Text("UPLOAD")),
          ),
        ),
        widget.addOrChange == "Change"
            ? Center(
                child: ElevatedButton(
                    onPressed: () {
                      showMaterialResponsiveDialog(
                          headerColor: Get.isDarkMode
                              ? Colors.black45
                              : selectedIconColor,
                          context: context,
                          title: "Are you sure?",
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "Are you sure you want to delete \"${widget.changeMaterial}\"? You won't be able to restore it.",
                                    style: TextStyle(fontSize: SmallTextSize),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          maxLongSide: 340,
                          onConfirmed: () {
                            if (widget.whichScreen == "Resources") {
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
                            } else {
                              FirebaseData().aeccOrGEData(
                                  context,
                                  widget.semester,
                                  widget.course,
                                  widget.materialType,
                                  widget.subject,
                                  3,
                                  widget.changeMaterial, {});
                            }
                          });
                    },
                    style: ElevatedButton.styleFrom(primary: selectedIconColor),
                    child: Text("DELETE")),
              )
            : Offstage()
      ],
    );
  }

  Future<void> _updatedOrUploadResources() async {
    if (_titleOfTheMaterial.text.trim() == "" ||
        _linkOfTheMaterial.text.trim() == "") {
      Fluttertoast.showToast(
          msg: "Material name and email can't be left blank.",
          toastLength: Toast.LENGTH_LONG);
    } else {
      try {
        await http.get(Uri.parse(_linkOfTheMaterial.text.trim()));
        if (widget.whichScreen == "Resources") {
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
          FirebaseData().aeccOrGEData(
              context,
              widget.semester,
              widget.course,
              widget.materialType,
              widget.subject,
              widget.addOrChange == "Add" ? 1 : 2,
              widget.changeMaterial, {
            "name": _titleOfTheMaterial.text.trim(),
            "link": _linkOfTheMaterial.text.trim()
          });
        }
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg:
                "Uploading failed. Please recheck your links.(check https:// or http:// also)",
            toastLength: Toast.LENGTH_LONG);
      }
    }
  }

  Future<void> _prefillTextField() async {
    try {
      if (widget.addOrChange == "Change") {
        if (widget.whichScreen == "Resources") {
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
        } else {
          List materialMap = await FirebaseData().aeccOrGEData(
              context,
              widget.semester,
              widget.course,
              widget.materialType,
              widget.subject,
              0,
              widget.changeMaterial, {});
          for (var material in materialMap) {
            if (material["name"] == widget.changeMaterial) {
              _titleOfTheMaterial.text = material["name"];
              _linkOfTheMaterial.text = material["link"];
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
