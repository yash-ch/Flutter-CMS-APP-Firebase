import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/screens/textFieldScreens/addOrChangeCourse.dart';
import 'package:cmseduc/screens/configureScreen.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class ChangeScreen extends StatefulWidget {
  final String changeItem;
  const ChangeScreen({Key? key, required this.changeItem}) : super(key: key);

  @override
  _ChangeScreenState createState() => _ChangeScreenState();
}

class _ChangeScreenState extends State<ChangeScreen> {
  bool _isLoading = true;
  Map _uploadedAtAndBy = {};
  List _courseList = [];

  //for resources
  List _materialList = [];
  List _subjectList = [];
  List _semesterList = [1, 2, 3, 4, 5, 6];

  Map _resourcesItemMap = {
    "Course": "none",
    "Material": "none",
    "Semester": "none"
  };

  bool _isEverythingSelected = false;

  @override
  void initState() {
    _loadInitialData();
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
            widget.changeItem,
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: selectedIconColor,
                  strokeWidth: 4.0,
                ),
              )
            : widget.changeItem == "Courses"
                ? configureCourse()
                : resourcesAddOrChange());
  }

  //screen for changing the courses and adding new
  Widget configureCourse() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(padding: EdgeInsets.all(5.0)),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(pageBuilder:
                          (BuildContext context, animation1, animation2) {
                        return AddOrChangeCourse(
                          addOrChange: "Add New",
                          changeCourse: "none",
                        );
                      }, transitionsBuilder:transitionEffectForNavigator()));
                },
                child: Container(
                  height: 100.0,
                  width: 100.0,
                  color: Get.isDarkMode ? offBlackColor : offWhiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_box_outlined,
                        color: selectedIconColor,
                        size: 50.0,
                      ),
                      Center(
                          child: Text(
                        "Add New",
                        style: TextStyle(fontSize: 12.0),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          lightTextWidget("Current Courses List"),
          Padding(padding: EdgeInsets.all(5.0)),
          Expanded(
            child: RefreshIndicator(
                onRefresh: _loadInitialData,
                child: _fullWidthListViewBuilder(context, _courseList)),
          )
        ]);
  }

  //for resources widget
  Widget resourcesAddOrChange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _chooseItemWidget(_materialList, "Material"),
        Padding(padding: EdgeInsets.all(5.0)),
        _chooseItemWidget(_courseList, "Course"),
        Padding(padding: EdgeInsets.all(5.0)),
        _chooseItemWidget(_semesterList, "Semester"),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                if (_resourcesItemMap.values.contains("none")) {
                  Fluttertoast.showToast(
                      msg: "Please select every field.",
                      toastLength: Toast.LENGTH_LONG);
                } else {
                  Fluttertoast.showToast(
                      msg: "Subjects list is loading, Please wait.",
                      toastLength: Toast.LENGTH_LONG);
                  _loadResourcesData();
                }
              },
              child: Text("Load Subjects"),
              style: ElevatedButton.styleFrom(primary: selectedIconColor),
            ),
          ),
        ),
        lightTextWidget("Subjects"),
        Padding(padding: EdgeInsets.all(5.0)),
        Expanded(
          child: _isEverythingSelected
              ? _fullWidthListViewBuilder(context, _subjectList)
              : Center(child: Text("No Subject Data")),
        )
      ],
    );
  }

  //for resources widget
  Widget _chooseItemWidget(List namesList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lightTextWidget("Select $title"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
          child: InkWell(
            onTap: () {
              showMaterialRadioPicker(
                context: context,
                items: namesList,
                selectedItem: _resourcesItemMap[title],
                title: title,
                onChanged: (value) {
                  _resourcesItemMap[title] = value.toString();
                  setState(() {});
                },
                maxLongSide: title == "Material"
                    ? 470
                    : title == "Semester"
                        ? 470
                        : 600,
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.0, 10.0, 5, 10),
                  color: Get.isDarkMode ? offBlackColor : offWhiteColor,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 0.0),
                        child:
                            Icon(Icons.list_rounded, color: selectedIconColor),
                      ),
                      Text(
                        _resourcesItemMap[title],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadInitialData() async {
    try {
      _courseList = await FirebaseData().courses();
      _materialList = await FirebaseData().materialType();

      if (widget.changeItem == "Courses") {
        for (var course in _courseList) {
          _uploadedAtAndBy[course] = await FirebaseData().uploadByAndAt(course);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> _loadResourcesData() async {
    try {
      _subjectList = await FirebaseData().subjectsOfCourse(
          _resourcesItemMap["Course"],
          int.parse(_resourcesItemMap["Semester"]));

      for (var subject in _subjectList) {
        List documentData = await FirebaseData().materialData(
            context,
            "none",
            "none",
            _resourcesItemMap["Course"],
            _resourcesItemMap["Material"],
            subject,
            int.parse(_resourcesItemMap["Semester"]),
            "none",
            "none");
        if (documentData.length != 0) {
          _uploadedAtAndBy[subject] = [
            documentData.first["updatedOn"],
            documentData.first["updatedBy"]
          ];
        } else {
          _uploadedAtAndBy[subject] = ["\'No Record\'", "\'No Record\'"];
        }
      }
      if (_subjectList.isNotEmpty) {
        setState(() {
          _isEverythingSelected = true;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Subjects are not available.", toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {}
  }

  Widget _fullWidthListViewBuilder(dynamic context, List namesList) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
              child: ListView.builder(
                  itemCount: namesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _fullWidthRoundedRectangleWidget(
                          context, namesList[index]),
                    );
                  }),
            )));
  }

  Widget _fullWidthRoundedRectangleWidget(dynamic context, String title) {
    // double widthOfBox = ((MediaQuery.of(context).size.width));
    return InkWell(
      focusColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          color: Get.isDarkMode ? offBlackColor : offWhiteColor,
          child: SizedBox(
            height: 100.0,
            // width: widthOfBox,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Icon(
                    Icons.edit,
                    color: selectedIconColor,
                    size: 35.0,
                  )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Last Updated on ${_uploadedAtAndBy[title][0]}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    ),
                    Text(
                      "By ${_uploadedAtAndBy[title][1]}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (BuildContext context, animation1, animation2) {
              return widget.changeItem == "Courses"
                  ? AddOrChangeCourse(
                      addOrChange: "Change",
                      changeCourse: title,
                    )
                  : ConfigureScreen(
                      whichScreen: "Resources",
                      resources: {
                        "materialType": _resourcesItemMap["Material"],
                        "subject": title,
                        "course": _resourcesItemMap["Course"],
                        "semester": int.parse(_resourcesItemMap["Semester"])
                      },
                      // users: {},
                    );
            }, transitionsBuilder:transitionEffectForNavigator()));
      },
    );
  }
}
