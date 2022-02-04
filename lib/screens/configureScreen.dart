import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/screens/textFieldScreens/addOrChangeEventsAndNews.dart';
import 'package:cmseduc/screens/textFieldScreens/addOrChangeResources.dart';
import 'package:cmseduc/screens/textFieldScreens/manageUsers.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:flutter/material.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:get/route_manager.dart';

class ConfigureScreen extends StatefulWidget {
  final String whichScreen;
  final Map resources;
  // final Map users;
  const ConfigureScreen({
    Key? key,
    required this.whichScreen,
    required this.resources,
    // required this.users
  }) : super(key: key);

  @override
  _ConfigureScreenState createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  List _documentsList = [];
  bool _isDocumentsLoaded = false;

  Map _updatedBy = {};
  Map _updatedOn = {};

  Map _eventDate = {}; //for all events

  @override
  void initState() {
    _loadMaterial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _pageTitle = "";
    switch (widget.whichScreen) {
      case "Resources":
        _pageTitle = widget.resources["subject"];
        break;
      case "AECC&GE":
        _pageTitle = widget.resources["subject"];
        break;
      default:
        _pageTitle = widget.whichScreen;
    }
    return Scaffold(
        backgroundColor:
            Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor,
          title: Text(
            _pageTitle,
            overflow: TextOverflow.ellipsis,
            style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isDocumentsLoaded
            ? Column(
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
                                    pageBuilder: (BuildContext context,
                                        animation1, animation2) {
                                      return (widget.whichScreen ==
                                                  "Resources" ||
                                              widget.whichScreen == "AECC&GE")
                                          ? AddOrChangeResources(
                                              whichScreen: widget.whichScreen,
                                              addOrChange: "Add",
                                              semester:
                                                  widget.resources["semester"],
                                              subject:
                                                  widget.resources["subject"],
                                              course:
                                                  widget.resources["aeccOrGE"],
                                              materialType: widget
                                                  .resources["materialType"],
                                              changeMaterial: "none",
                                            )
                                          : widget.whichScreen == "Manage Users"
                                              ? ManageUsers(
                                                  addOrChange: "Add",
                                                  previousUserName: "none")
                                              : AddOrChangeEventsAndNews(
                                                  whichEvents:
                                                      widget.whichScreen,
                                                  addOrChange: "Add",
                                                  changeEvent: "none",
                                                );
                                    },
                                    transitionsBuilder:
                                        transitionEffectForNavigator()));
                          },
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            color:
                                Get.isDarkMode ? offBlackColor : offWhiteColor,
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
                      child: lightTextWidget("Current $_pageTitle List"),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                          onRefresh: _loadMaterial,
                          child: _fullWidthListViewBuilder(
                              context, _documentsList)),
                    )
                  ])
            : Center(
                child: CircularProgressIndicator(
                  color: selectedIconColor,
                  strokeWidth: 4,
                ),
              ));
  }

  Future<void> _loadMaterial() async {
    try {
      switch (widget.whichScreen) {
        case "Resources":
          _documentsList = [];
          List documentData = await FirebaseData().materialData(
              context,
              "none",
              "none",
              widget.resources["course"],
              widget.resources["materialType"],
              widget.resources["subject"],
              widget.resources["semester"],
              "none",
              "none");

          for (var material in documentData) {
            _documentsList.add(material["name"]);
            _updatedBy[material["name"]] = material["updatedBy"];
            _updatedOn[material["name"]] = material["updatedOn"];
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
          break;
        case "Manage Users":
          _documentsList = [];
          _updatedOn = {};

          Map userData = await FirebaseData().allUsers();
          for (var user in userData.keys) {
            _documentsList.add(user);
            _updatedBy[user] = userData[user]
                ["email"]; //for showing email id of user that admin has updated

            if (userData[user]["isAdmin"]) {
              _updatedOn[user] = "Admin,"; //for showing the access the user has
            }
            if (userData[user]["courseAccess"]) {
              if (_updatedOn[user] == null) {
                _updatedOn[user] = "CourseAccess";
              } else {
                _updatedOn[user] = _updatedOn[user] + " CourseAccess";
              }
            }
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
          break;
        case "Top Banners":
          _documentsList = [];
          List eventsData = await FirebaseData().eventsData("top_banners");
          for (var event in eventsData) {
            _documentsList.add(event["name"]);
            _updatedBy[event["name"]] = event["uploadedBy"];
            _updatedOn[event["name"]] = event["uploadedOn"];
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
          break;
        case "Events":
          _documentsList = [];
          List eventsData = await FirebaseData().eventsData("all_events");
          for (var event in eventsData) {
            _documentsList.add(event["name"]);
            _updatedBy[event["name"]] = event["uploadedBy"];
            _updatedOn[event["name"]] = event["uploadedOn"];
            _eventDate[event["name"]] = event["event_date"];
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
          break;
        case "AECC&GE":
          _documentsList = [];
          List aeccGEData = await FirebaseData().aeccOrGEData(context,
              widget.resources["semester"],
              widget.resources["aeccOrGE"],
              widget.resources["materialType"],
              widget.resources["subject"],
              0, "none",{});
          for (var material in aeccGEData) {
            _documentsList.add(material["name"]);
            _updatedBy[material["name"]] = material["updatedBy"];
            _updatedOn[material["name"]] = material["updatedOn"];
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
        break;
        case "News":
          _documentsList = [];
          List eventsData = await FirebaseData().newsData();
          for (var event in eventsData) {
            _documentsList.add(event["name"]);
            _updatedBy[event["name"]] = event["uploadedBy"];
            _updatedOn[event["name"]] = event["uploadedOn"];
            _eventDate[event["name"]] = event["event_date"];
          }
          setState(() {
            _isDocumentsLoaded = true;
          });
          break;
      }
    } catch (e) {
      print(e);
    }
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
                    widget.whichScreen == "Events"
                        ? Text(
                            "Event date " +
                                _eventDate[title]
                                    .toString()
                                    .replaceAll(RegExp(r' '), '/'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Get.isDarkMode
                                    ? darkModeLightTextColor
                                    : lightModeLightTextColor,
                                fontSize: 12),
                          )
                        : Offstage(),
                    Text(
                      widget.whichScreen == "Manage Users"
                          ? "Email : ${_updatedBy[title]}" //for email
                          : "Last updated on ${_updatedOn[title]}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    ),
                    Text(
                      widget.whichScreen == "Manage Users"
                          ? "Roles : ${_updatedOn[title]}"
                          : "By ${_updatedBy[title]}",
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
                  return (widget.whichScreen == "Resources" ||widget.whichScreen == "AECC&GE")
                      ? AddOrChangeResources(
                          whichScreen: widget.whichScreen,
                          addOrChange: "Change",
                          semester: widget.resources["semester"],
                          subject: widget.resources["subject"],
                          course: widget.resources["aeccOrGE"],
                          materialType: widget.resources["materialType"],
                          changeMaterial: title)
                      : widget.whichScreen == "Manage Users"
                          ? ManageUsers(
                              addOrChange: "Change", previousUserName: title)
                          : AddOrChangeEventsAndNews(
                              whichEvents: widget.whichScreen,
                              addOrChange: "Change",
                              changeEvent: title,
                            );
                },
                transitionsBuilder: transitionEffectForNavigator()));
      },
    );
  }
}
