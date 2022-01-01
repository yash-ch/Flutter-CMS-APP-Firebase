import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

List courseList = [];

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  bool isProcessComplete = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Settings",
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 10.0, 0, 10.0),
              child: Text(
                "Update or Control",
                style: Get.isDarkMode
                    ? darkModeLightTextStyle
                    : lightModeLightTextStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roundedRectangleWidget(context, "Material Collection"),
              ],
            ),
            Center(
              child: Visibility(
                visible: isProcessComplete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: CircularProgressIndicator(
                    color: selectedIconColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {
    courseList = await FirebaseData().courses();
    // for (var item in courseList) {
    //   FirebaseData().addingSemesterNoAndCourse("Youtube Playlists", item, true);
    //   break;
    // }
  }

  Widget roundedRectangleWidget(dynamic context, String title) {
    double widthOfBox = ((MediaQuery.of(context).size.width) / 2) - 30;
    return InkWell(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          color: Get.isDarkMode ? offBlackColor : offWhiteColor,
          child: SizedBox(
            height: 100.0,
            width: widthOfBox,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: Icon(
                  Icons.blur_circular_rounded,
                  color: selectedIconColor,
                  size: 35.0,
                )),
                SizedBox(
                    width: widthOfBox / 1.8,
                    child: Text(
                      title,
                    )),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        _materialCollectionOnTap();
      },
    );
  }

  void _materialCollectionOnTap() {
    String course = "Select Course";
    showMaterialRadioPicker(
        title: "Select Course",
        context: context,
        items: courseList,
        onChanged: (value) {
          setState(() {
            course = value.toString();
          });
        },
        onConfirmed: () {
          showMaterialRadioPicker(
            maxLongSide: 320.0,
            context: context,
            items: ["Update Subjects", "Delete none", "Do Both"],
            title: "Options",
            onChanged: (value) {
              if (value == "Update Subjects") {
                approveMaterialCollection(course, false, true);
              } else if (value == "Delete none") {
                approveMaterialCollection(course, true, false);
              } else if (value == "Do Both") {
                approveMaterialCollection(course, true, true);
              }
            },
          );
        });
  }

  void approveMaterialCollection(
      String courseName, bool deleteNone, bool updateSubject) async {
    setState(() {
      isProcessComplete = true;
    });
    if (updateSubject) {
      await FirebaseData().updateCoursesSubject(courseName, false, false);
      await FirebaseData().updateCoursesSubject(courseName, true, false);
    }
    if (deleteNone) {
      await FirebaseData().updateCoursesSubject(courseName, false, true);
    }
    Fluttertoast.showToast(
        msg: "Processing Completed", toastLength: Toast.LENGTH_LONG);
    setState(() {
      isProcessComplete = false;
    });
    // int i = 1;
    // List courseList =
    // [
    //   "B.Sc. (H) Computer Science",
    //   "B.Sc. (H) Mathematics"
    // ];
    // // await FirebaseData().courses();
    // List materialList =
    // ["Notes","Books"];
    // // await FirebaseData().materialType();
    // for (var material in materialList) {
    //   print("material : $i");
    //   for (var course in courseList) {
    //     await FirebaseData().addingSemesterNoAndCourse(material, course);
    //   }
    //   i =i+1;
    // }
  }
}
