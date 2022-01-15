import 'package:cmseduc/screens/changeScreen.dart';
import 'package:cmseduc/screens/settingsScreen.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
          title: Text(
            "CMS educircle",
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: IconButton(
                    onPressed: _settingsOnTap,
                    icon: Icon(
                      Icons.settings,
                    )))
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lightTextWidget("Configure"),
                Padding(padding: EdgeInsets.all(5.0)),
                rectangleListViewBuilder(context, ["Courses"]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0, 10.0),
                  child: Text(
                    "Add Or Change",
                    style: Get.isDarkMode
                        ? darkModeLightTextStyle
                        : lightModeLightTextStyle,
                  ),
                ),
                rectangleListViewBuilder(
                    context, ["Resources", "Top Banners", "Events"]),
              ],
            ),
          ),
        ));
  }

  Future<void> _settingsOnTap() async {
    bool isAdmin = await FirebaseData().userRole("isAdmin");
    if (isAdmin) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (BuildContext context, animation1, animation2) {
            return SettingsScreen();
          }, transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.linearToEaseOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          }));
    } else {
      Fluttertoast.showToast(
          msg: "Sorry, only admin(s) are allowed.",
          toastLength: Toast.LENGTH_LONG);
    }
  }
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

Widget roundedRectangleWidget(dynamic context, String changeItem) {
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
                Icons.account_tree_rounded,
                color: selectedIconColor,
                size: 35.0,
              )),
              SizedBox(
                  width: widthOfBox / 1.8,
                  child: Text(
                    changeItem,
                    style: TextStyle(fontSize: SmallTextSize),
                  )),
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
                return ChangeScreen(changeItem: changeItem);
              },
              transitionsBuilder: transitionEffectForNavigator()));
    },
  );
}

transitionEffectForNavigator() {
  return (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.linearToEaseOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  };
}

Widget lightTextWidget(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0, 0.0),
    child: Text(
      title,
      style: Get.isDarkMode ? darkModeLightTextStyle : lightModeLightTextStyle,
    ),
  );
}
