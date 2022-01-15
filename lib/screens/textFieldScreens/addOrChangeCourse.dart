import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class AddOrChangeCourse extends StatefulWidget {
  final String addOrChange;
  final String changeCourse;
  const AddOrChangeCourse(
      {Key? key, required this.addOrChange, required this.changeCourse})
      : super(key: key);
  @override
  AddOrChangeCourseState createState() => AddOrChangeCourseState();
}

class AddOrChangeCourseState extends State<AddOrChangeCourse> {
  final TextEditingController nameOfTheCourseController =
      TextEditingController();
  final TextEditingController newSubjectNameController =
      TextEditingController();

  List allSemSubMapsList = [{}, {}, {}, {}, {}, {}];

  @override
  void initState() {
    prefillTextField();
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
            widget.addOrChange + " Course",
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: addOrChangeCourseWidget(),
        ));
  }

  Widget addOrChangeCourseWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lightTextWidget("Course"),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 20.0),
            child: TextField(
              cursorColor: selectedIconColor,
              controller: nameOfTheCourseController,
              decoration: InputDecoration(
                labelText: "Course Name",
              ),
            ),
          ),
          _subjectsListViewBuilder(1, allSemSubMapsList[0]),
          _subjectsListViewBuilder(2, allSemSubMapsList[1]),
          _subjectsListViewBuilder(3, allSemSubMapsList[2]),
          _subjectsListViewBuilder(4, allSemSubMapsList[3]),
          _subjectsListViewBuilder(5, allSemSubMapsList[4]),
          _subjectsListViewBuilder(6, allSemSubMapsList[5]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 0.0),
            child: Text(
              (widget.addOrChange == "Change" ? "Update" : "Upload") +
                  " it even if you don't have all the subjects of the course, subjects can be edited later.",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: selectedIconColor),
                  onPressed: () {
                    // print(sem1SubMap);
                    _onTapUpdateOrUpload();
                  },
                  child: widget.addOrChange == "Change"
                      ? Text("UPDATE")
                      : Text("UPLOAD")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectsListViewBuilder(int semester, Map subjectMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lightTextWidget(
          "Semester $semester Subjects",
        ),
        subjectMap.isNotEmpty
            ? Padding(
                padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: subjectMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            _addOrChangeSubject(
                                semester, subjectMap, false, index + 1);
                          },
                          child: Container(
                            color:
                                Get.isDarkMode ? offBlackColor : offWhiteColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.all(3)),
                                lightTextWidget("Subject ${index + 1}"),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 10.0, 16.0, 16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.circle, size: 10.0),
                                      Container(
                                        width: getDeviceWidth(context) - 80,
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          subjectMap[index + 1],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              )
            : Center(
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "No subjects",
                  style: TextStyle(
                      color: Get.isDarkMode
                          ? darkModeLightTextColor
                          : lightModeLightTextColor),
                ),
              )),
        Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: selectedIconColor),
              onPressed: () {
                _addOrChangeSubject(
                    semester, subjectMap, true, subjectMap.length + 1);
              },
              child: Text("Add New")),
        ),
      ],
    );
  }

  void _addOrChangeSubject(
      int semester, Map subjectsMap, bool addOrChange, int subjectNo) {
    //true for add and false for change
    if (!addOrChange) {
      newSubjectNameController.text = subjectsMap[subjectNo];
    } else {
      newSubjectNameController.text = "";
    }
    showMaterialResponsiveDialog(
        context: context,
        title:
            addOrChange ? "Add Subject $subjectNo" : "Add Subject $subjectNo",
        headerColor: selectedIconColor,
        maxLongSide: 340.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lightTextWidget("Enter Subject Name"),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 10.0),
              child: TextField(
                controller: newSubjectNameController,
                decoration: InputDecoration(
                  labelText: "Subject",
                ),
              ),
            ),
            !addOrChange
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: selectedIconColor),
                          onPressed: () {
                            setState(() {
                              subjectsMap.removeWhere(
                                  (key, value) => key == subjectNo);
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("Delete")),
                    ),
                  )
                : Offstage(),
            Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 00.0),
                child: Text("Do click the update button in the bottom.")),
          ],
        ),
        onConfirmed: () {
          setState(() {
            subjectsMap[subjectNo] = newSubjectNameController.text.trim();
          });
        });
  }

  Future<void> _onTapUpdateOrUpload() async {
    bool _courseAccess = await FirebaseData().userRole("courseAccess");
    if (_courseAccess) {
      if (nameOfTheCourseController.text.trim() != "") {
        FirebaseData().addOrChangeCourse(
            context,
            widget.addOrChange == "Change" ? false : true,
            widget.changeCourse,
            nameOfTheCourseController.text.trim(),
            creatingSubjectList(1),
            creatingSubjectList(2),
            creatingSubjectList(3),
            creatingSubjectList(4),
            creatingSubjectList(5),
            creatingSubjectList(6));
      } else {
        Fluttertoast.showToast(
            msg: "Course name can't be left blank.",
            toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Sorry, you don't have access to configure course.",
          toastLength: Toast.LENGTH_LONG);
    }
  }

  List creatingSubjectList(int semester) {
    //for firebase....needs list but we have map for subjects
    List _subjectList = [];
    for (var i = 1;
        i < allSemSubMapsList.elementAt(semester - 1).length + 1;
        i++) {
      _subjectList.add(allSemSubMapsList.elementAt(semester - 1)[i]);
    }
    return _subjectList;
  }

  Future<void> prefillTextField() async {
    try {
      if (widget.addOrChange == "Change") {
        Map firebaseSubjectMap =
            await FirebaseData().subjectMapOfCourse(widget.changeCourse);
        nameOfTheCourseController.text = widget.changeCourse;

        setState(() {
          for (var i = 1; i < 7; i++) {
            _fillingSubjectMap(firebaseSubjectMap, i);
          }
        });
      }
    } catch (e) {}
  }

  void _fillingSubjectMap(Map subjectMap, int semester) {
    for (var i = 0; i < subjectMap["sem$semester"].length; i++) {
      if (subjectMap["sem$semester"][i] != "") {
        allSemSubMapsList[semester - 1][i + 1] = subjectMap["sem$semester"][i];
      }
    }
  }
}
