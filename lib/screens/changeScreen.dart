import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/screens/configureScreen.dart';
import 'package:cmseduc/screens/textFieldScreens/addOrChangeCourse.dart';
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

  //for aecc &ge
  bool _onAddNewSubject = false;

  Map _resourcesItemMap = {
    "Course": "none",
    "Material": "none",
    "Semester": "none",
    "AECC or GE": "none"
  };

  //for GE or AECC
  final TextEditingController newSubjectNameController =
      TextEditingController();

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
            : (widget.changeItem == "Courses")
                ? configureCourse()
                : widget.changeItem == "Resources"
                    ? resourcesAddOrChange()
                    : manageAeccOrGE());
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
                borderRadius: BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder:
                              (BuildContext context, animation1, animation2) {
                            return AddOrChangeCourse(
                              addOrChange: "Add New",
                              changeCourse: "none",
                            );
                          },
                          transitionsBuilder: transitionEffectForNavigator()));
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 16.0),
            child: lightTextWidget("Current Courses List"),
          ),
          Expanded(
            child: RefreshIndicator(
                onRefresh: _loadInitialData,
                child: _fullWidthListViewBuilder(context, _courseList)),
          )
        ]);
  }

  Widget manageAeccOrGE() {
    _resourcesItemMap["Course"] = "aeccsonotnone"; //for line 157
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _chooseItemWidget(_materialList, "Material"),
        Padding(padding: EdgeInsets.all(5.0)),
        _chooseItemWidget(["AECC", "GE"], "AECC or GE"),
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
                  _loadAeccOrGEData();
                }
              },
              child: Text("Load Subjects"),
              style: ElevatedButton.styleFrom(primary: selectedIconColor),
            ),
          ),
        ),
        _onAddNewSubject
            ? Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: selectedIconColor),
                    onPressed: () {
                      newSubjectNameController.text = "";
                      addOrChangeSubjectButtonTap(0, "none");
                    },
                    child: Text("Add New Subject")),
              )
            : Offstage(),
        lightTextWidget("Subjects"),
        Padding(padding: EdgeInsets.all(5.0)),
        Expanded(
          child: _isEverythingSelected
              ? RefreshIndicator(
                  onRefresh: _loadAeccOrGEData,
                  child: _fullWidthListViewBuilder(context, _subjectList))
              : Center(child: Text("No Subject Data")),
        )
      ],
    );
  }

  //for AECC or GE
  void addOrChangeSubjectButtonTap(
      int addOrChangeOrDelete, String previousName) {
    showMaterialResponsiveDialog(
        context: context,
        title: addOrChangeOrDelete == 0 ? "Add New Subject" : "Update Subject",
        headerColor: Get.isDarkMode ? Colors.black45 : selectedIconColor,
        maxLongSide: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lightTextWidget("Enter Subject Name"),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0),
              child: TextField(
                controller: newSubjectNameController,
                decoration: InputDecoration(
                  labelText: "Subject",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: selectedIconColor),
                    onPressed: () async {
                      _onTapAddUploadOrDelete(
                          addOrChangeOrDelete, previousName);
                    },
                    child: Text(addOrChangeOrDelete == 0 ? "Add" : "Update")),
              ),
            ),
            addOrChangeOrDelete == 1 //false for change
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: selectedIconColor),
                          onPressed: () {
                            _onTapAddUploadOrDelete(2, previousName);
                          },
                          child: Text("Delete")),
                    ),
                  )
                : Offstage(),
          ],
        ));
  }

  Future<void> _onTapAddUploadOrDelete(
      int addOrChangeOrDelete, String previousName) async {
    Fluttertoast.showToast(
        msg: "Please wait, processing", toastLength: Toast.LENGTH_SHORT);
    await FirebaseData().manageAeccOrGESubjects(
        int.parse(_resourcesItemMap["Semester"]),
        _resourcesItemMap["AECC or GE"],
        newSubjectNameController.text,
        addOrChangeOrDelete,
        previousName);
    Fluttertoast.showToast(
        msg: newSubjectNameController.text +
            " has been " +
            (addOrChangeOrDelete == 2
                ? "deleted"
                : addOrChangeOrDelete == 1
                    ? "updated"
                    : "added"),
        toastLength: Toast.LENGTH_SHORT);
    _loadAeccOrGEData();
    Navigator.of(context).pop();
  }

  //for resources widget
  Widget resourcesAddOrChange() {
    _resourcesItemMap["AECC or GE"] = "notnone";
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
            borderRadius: BorderRadius.all(Radius.circular(20)),
            onTap: () {
              showMaterialRadioPicker(
                headerColor:
                    Get.isDarkMode ? Colors.black45 : selectedIconColor,
                context: context,
                items: namesList,
                selectedItem: _resourcesItemMap[title],
                title: title,
                onChanged: (value) {
                  _resourcesItemMap[title] = value.toString();
                  if (value.toString() == "AECC") {
                    _semesterList = [1, 3, 5];
                  }else if (value.toString() == "GE"){
                    _semesterList = [1,2,3,4];
                  }
                  setState(() {});
                },
                maxLongSide: (title == "Material" || title == "Semester")
                    ? 470
                    : (title == "AECC or GE")
                        ? 340
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
      switch (widget.changeItem) {
        case "Courses":
          _courseList = await FirebaseData().courses();
          _materialList = await FirebaseData().materialType();
          for (var course in _courseList) {
            _uploadedAtAndBy[course] =
                await FirebaseData().uploadByAndAt(course);
          }
          break;
        case "Resources":
          _courseList = await FirebaseData().courses();
          _materialList = await FirebaseData().materialType();
          break;
        case "AECC & GE":
          _materialList = await FirebaseData().materialType();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {}
  }

  Future<void> _loadAeccOrGEData() async {
    _subjectList = await FirebaseData().aeccGESubjects(
        int.parse(_resourcesItemMap["Semester"]),
        _resourcesItemMap["AECC or GE"]);
    for (var subject in _subjectList) {
      List documentData = await FirebaseData().aeccOrGEData(
          context,
          int.parse(_resourcesItemMap["Semester"]),
          _resourcesItemMap["AECC or GE"],
          _resourcesItemMap["Material"],
          subject,
          0,
          "none", {});
      print(documentData);
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
        _onAddNewSubject = true;
      });
    } else {
      setState(() {
        _isEverythingSelected = false;
        _onAddNewSubject = true;
      });

      Fluttertoast.showToast(
          msg: "Subjects are not available.", toastLength: Toast.LENGTH_SHORT);
    }
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
      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                    Container(
                      width: getDeviceWidth(context) - 100,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                      ),
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
        switch (widget.changeItem) {
          case "AECC & GE":
            showMaterialResponsiveDialog(
                context: context,
                headerColor:
                    Get.isDarkMode ? Colors.black45 : selectedIconColor,
                maxLongSide: 340.0,
                title: "Select",
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("What do you want to do?"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            newSubjectNameController.text = title;
                            addOrChangeSubjectButtonTap(1, title);
                          },
                          child: Text("Change Subject Name"),
                          style: ElevatedButton.styleFrom(
                              primary: selectedIconColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (BuildContext context,
                                        animation1, animation2) {
                                      return ConfigureScreen(
                                        whichScreen: "AECC&GE",
                                        resources: {
                                          "aeccOrGE":
                                              _resourcesItemMap["AECC or GE"],
                                          "semester": int.parse(
                                              _resourcesItemMap["Semester"]),
                                          "materialType":
                                              _resourcesItemMap["Material"],
                                          "subject": title,
                                          "course": "none"
                                        },
                                      );
                                    },
                                    transitionsBuilder:
                                        transitionEffectForNavigator()));
                          },
                          child: Text("Add Material for Subject"),
                          style: ElevatedButton.styleFrom(
                              primary: selectedIconColor),
                        ),
                      )
                    ],
                  ),
                ));

            break;
          default:
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder:
                        (BuildContext context, animation1, animation2) {
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
                                "semester":
                                    int.parse(_resourcesItemMap["Semester"])
                              },
                            );
                    },
                    transitionsBuilder: transitionEffectForNavigator()));
        }
      },
    );
  }
}
