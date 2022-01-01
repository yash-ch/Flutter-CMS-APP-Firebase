import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class AddOrChangeCourse extends StatefulWidget {
  final String addOrChange;
  final String changeCourse;
  const AddOrChangeCourse(
      {Key? key, required this.addOrChange, required this.changeCourse})
      : super(key: key);

  @override
  _AddOrChangeCourseState createState() => _AddOrChangeCourseState();
}

class _AddOrChangeCourseState extends State<AddOrChangeCourse> {
  final TextEditingController nameOfTheCourseController =
      TextEditingController();
  final TextEditingController sem1Sub1 = TextEditingController();
  final TextEditingController sem1Sub2 = TextEditingController();
  final TextEditingController sem1Sub3 = TextEditingController();
  final TextEditingController sem1Sub4 = TextEditingController();
  final TextEditingController sem1Sub5 = TextEditingController();

  final TextEditingController sem2Sub1 = TextEditingController();
  final TextEditingController sem2Sub2 = TextEditingController();
  final TextEditingController sem2Sub3 = TextEditingController();
  final TextEditingController sem2Sub4 = TextEditingController();
  final TextEditingController sem2Sub5 = TextEditingController();

  final TextEditingController sem3Sub1 = TextEditingController();
  final TextEditingController sem3Sub2 = TextEditingController();
  final TextEditingController sem3Sub3 = TextEditingController();
  final TextEditingController sem3Sub4 = TextEditingController();
  final TextEditingController sem3Sub5 = TextEditingController();

  final TextEditingController sem4Sub1 = TextEditingController();
  final TextEditingController sem4Sub2 = TextEditingController();
  final TextEditingController sem4Sub3 = TextEditingController();
  final TextEditingController sem4Sub4 = TextEditingController();
  final TextEditingController sem4Sub5 = TextEditingController();

  final TextEditingController sem5Sub1 = TextEditingController();
  final TextEditingController sem5Sub2 = TextEditingController();
  final TextEditingController sem5Sub3 = TextEditingController();
  final TextEditingController sem5Sub4 = TextEditingController();
  final TextEditingController sem5Sub5 = TextEditingController();

  final TextEditingController sem6Sub1 = TextEditingController();
  final TextEditingController sem6Sub2 = TextEditingController();
  final TextEditingController sem6Sub3 = TextEditingController();
  final TextEditingController sem6Sub4 = TextEditingController();
  final TextEditingController sem6Sub5 = TextEditingController();

  List sem1List = [];
  List sem2List = [];
  List sem3List = [];
  List sem4List = [];
  List sem5List = [];
  List sem6List = [];

  void setSemList() {
    setState(() {
      sem1List = [
        sem1Sub1.text.trim(),
        sem1Sub2.text.trim(),
        sem1Sub3.text.trim(),
        sem1Sub4.text.trim(),
        sem1Sub5.text.trim()
      ];
      sem2List = [
        sem2Sub1.text.trim(),
        sem2Sub2.text.trim(),
        sem2Sub3.text.trim(),
        sem2Sub4.text.trim(),
        sem2Sub5.text.trim()
      ];
      sem3List = [
        sem3Sub1.text.trim(),
        sem3Sub2.text.trim(),
        sem3Sub3.text.trim(),
        sem3Sub4.text.trim(),
        sem3Sub5.text.trim()
      ];
      sem4List = [
        sem4Sub1.text.trim(),
        sem4Sub2.text.trim(),
        sem4Sub3.text.trim(),
        sem4Sub4.text.trim(),
        sem4Sub5.text.trim()
      ];
      sem5List = [
        sem5Sub1.text.trim(),
        sem5Sub2.text.trim(),
        sem5Sub3.text.trim(),
        sem5Sub4.text.trim(),
        sem5Sub5.text.trim()
      ];
      sem6List = [
        sem6Sub1.text.trim(),
        sem6Sub2.text.trim(),
        sem6Sub3.text.trim(),
        sem6Sub4.text.trim(),
        sem6Sub5.text.trim()
      ];
    });
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
    prefillTextField();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 10.0, 0, 10.0),
          child: Text(
            "Course",
            style: TextStyle(fontSize: SmallTextSize, color: selectedIconColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 20.0),
          child: TextField(
            controller: nameOfTheCourseController,
            decoration: InputDecoration(
              labelText: "Course Name",
            ),
          ),
        ),
        fullWidthListViewBuilder(
            context,
            1,
            [sem1Sub1, sem1Sub2, sem1Sub3, sem1Sub4, sem1Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        fullWidthListViewBuilder(
            context,
            2,
            [sem2Sub1, sem2Sub2, sem2Sub3, sem2Sub4, sem2Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        fullWidthListViewBuilder(
            context,
            3,
            [sem3Sub1, sem3Sub2, sem3Sub3, sem3Sub4, sem3Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        fullWidthListViewBuilder(
            context,
            4,
            [sem4Sub1, sem4Sub2, sem4Sub3, sem4Sub4, sem4Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        fullWidthListViewBuilder(
            context,
            5,
            [sem5Sub1, sem5Sub2, sem5Sub3, sem5Sub4, sem5Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        fullWidthListViewBuilder(
            context,
            6,
            [sem6Sub1, sem6Sub2, sem6Sub3, sem6Sub4, sem6Sub5],
            ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"]),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 10.0, 0, 0.0),
          child: Text(
            (widget.addOrChange == "Change" ? "Update" : "Upload") +
                " it even if you don't have all the subjects of the course, subjects can be edited later.",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: selectedIconColor),
                onPressed: () {
                  if (nameOfTheCourseController.text.trim() != "") {
                    setSemList();
                    FirebaseData().addOrChangeCourse(
                        context,
                        widget.addOrChange == "Change" ? false : true,
                        widget.changeCourse,
                        nameOfTheCourseController.text.trim(),
                        sem1List,
                        sem2List,
                        sem3List,
                        sem4List,
                        sem5List,
                        sem6List);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Course name can't be left blank.",
                        toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: widget.addOrChange == "Change"
                    ? Text("UPDATE")
                    : Text("UPLOAD")),
          ),
        ),
      ],
    );
  }

  Widget fullWidthListViewBuilder(
      dynamic context, int sem, List controllerList, List itemList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 10.0, 0, 10.0),
          child: Text(
            "Semester $sem Subjects",
            style: TextStyle(fontSize: SmallTextSize, color: selectedIconColor),
          ),
        ),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: itemList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 10.0),
                child: TextField(
                  controller: controllerList[index],
                  decoration: InputDecoration(
                    labelText: itemList[index],
                  ),
                ),
              );
            }),
      ],
    );
  }

  Future<void> prefillTextField() async {
    try {
      if (widget.addOrChange == "Change") {
        Map subjectMap =
            await FirebaseData().subjectMapOfCourse(widget.changeCourse);
        nameOfTheCourseController.text = widget.changeCourse;

        sem1Sub1.text = subjectMap["sem1"][0];
        sem1Sub2.text = subjectMap["sem1"][1];
        sem1Sub3.text = subjectMap["sem1"][2];
        sem1Sub4.text = subjectMap["sem1"][3];
        sem1Sub5.text = subjectMap["sem1"][4];

        sem2Sub1.text = subjectMap["sem2"][0];
        sem2Sub2.text = subjectMap["sem2"][1];
        sem2Sub3.text = subjectMap["sem2"][2];
        sem2Sub4.text = subjectMap["sem2"][3];
        sem2Sub5.text = subjectMap["sem2"][4];

        sem3Sub1.text = subjectMap["sem3"][0];
        sem3Sub2.text = subjectMap["sem3"][1];
        sem3Sub3.text = subjectMap["sem3"][2];
        sem3Sub4.text = subjectMap["sem3"][3];
        sem3Sub5.text = subjectMap["sem3"][4];

        sem4Sub1.text = subjectMap["sem4"][0];
        sem4Sub2.text = subjectMap["sem4"][1];
        sem4Sub3.text = subjectMap["sem4"][2];
        sem4Sub4.text = subjectMap["sem4"][3];
        sem4Sub5.text = subjectMap["sem4"][4];

        sem5Sub1.text = subjectMap["sem5"][0];
        sem5Sub2.text = subjectMap["sem5"][1];
        sem5Sub3.text = subjectMap["sem5"][2];
        sem5Sub4.text = subjectMap["sem5"][3];
        sem5Sub5.text = subjectMap["sem5"][4];

        sem6Sub1.text = subjectMap["sem6"][0];
        sem6Sub2.text = subjectMap["sem6"][1];
        sem6Sub3.text = subjectMap["sem6"][2];
        sem6Sub4.text = subjectMap["sem6"][3];
        sem6Sub5.text = subjectMap["sem6"][4];
      }
    } catch (e) {}
  }
}
