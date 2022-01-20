import 'package:cmseduc/screens/configureScreen.dart';
import 'package:cmseduc/screens/mainScreen.dart';
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
    // FirebaseData().addingGEAndAecc("Books");
    // FirebaseData().manageGEorAeccSubjects(1,"GE","none", false, "EVS");
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
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
              child: lightTextWidget("Update or Control"),
            ),
            rectangleListViewBuilder(
                context, ["Material Collection", "Manage Users"]),
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

  Widget rectangleListViewBuilder(dynamic context, List changeItemList) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: changeItemList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              index % 2 == 0 || index == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        roundedRectangleWidget(context, changeItemList[index]),
                        SizedBox(
                          width: 20,
                        ),
                        changeItemList.length > index + 1
                            ? roundedRectangleWidget(
                                context, changeItemList[index + 1])
                            : Offstage()
                      ],
                    )
                  : Offstage(),
              SizedBox(
                height: 10,
              )
            ],
          );
        });
  }

  Widget roundedRectangleWidget(dynamic context, String title) {
    double widthOfBox = ((MediaQuery.of(context).size.width) / 2) - 30;
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(20)),
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
        switch (title) {
          case "Material Collection":
            _materialCollectionOnTap();
            break;
          case "Manage Users":
            openConfigureScreen(context, title);
            break;
        }
      },
    );
  }

  void _materialCollectionOnTap() {
    String course = "Select Course";
    showMaterialRadioPicker(
        title: "Select Course",
        context: context,
        headerColor: Get.isDarkMode ? Colors.black45 : selectedIconColor,
        items: courseList,
        onChanged: (value) {
          setState(() {
            course = value.toString();
          });
        },
        onConfirmed: () {
          approveMaterialCollection(course);
        });
  }

  void approveMaterialCollection(String courseName) async {
    setState(() {
      isProcessComplete = true;
    });
    await FirebaseData().updateCoursesSubject(courseName);

    Fluttertoast.showToast(
        msg: "Processing Completed", toastLength: Toast.LENGTH_LONG);
    setState(() {
      isProcessComplete = false;
    });
  }
}

void openConfigureScreen(context, String screenName) {
  //for Manage users
  Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (BuildContext context, animation1, animation2) {
            return ConfigureScreen(
              whichScreen: screenName,
              resources: {},
              // users: {},
            );
          },
          transitionsBuilder: transitionEffectForNavigator()));
}
