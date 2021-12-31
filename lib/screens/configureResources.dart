import 'package:cmseduc/screens/addOrChangeResources.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:flutter/material.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:get/route_manager.dart';

class ConfigureResources extends StatefulWidget {
  final String course;
  final String subject;
  final String materialType;
  final int semester;

  const ConfigureResources(
      {Key? key,
      required this.materialType,
      required this.subject,
      required this.course,
      required this.semester})
      : super(key: key);

  @override
  _ConfigureResourcesState createState() => _ConfigureResourcesState();
}

class _ConfigureResourcesState extends State<ConfigureResources> {
  List _documentsList = [];
  bool _isDocumentsLoaded = false;

  Map _updatedBy = {};
  Map _updatedOn = {};

  @override
  void initState() {
    _loadMaterial();
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
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(pageBuilder:
                                    (BuildContext context, animation1,
                                        animation2) {
                                  return AddOrChangeResources(
                                    addOrChange: "Add",
                                    semester: widget.semester,
                                    subject: widget.subject,
                                    course: widget.course,
                                    materialType: widget.materialType,
                                    changeMaterial: "none",
                                  );
                                }, transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.linearToEaseOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                }));
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
                    _lightTextWidget("Current ${widget.materialType} List"),
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

  Widget _lightTextWidget(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0, 10.0),
      child: Text(
        title,
        style:
            Get.isDarkMode ? darkModeLightTextStyle : lightModeLightTextStyle,
      ),
    );
  }

  Future<void> _loadMaterial() async {
    try {
      _documentsList = [];
      List documentData = await FirebaseData().materialData(
          context,
          "none",
          "none",
          widget.course,
          widget.materialType,
          widget.subject,
          widget.semester,
          "none",
          "none");

      for (var item in documentData) {
        _documentsList.add(item["name"]);
        _updatedBy[item["name"]] = item["updatedBy"];
        _updatedOn[item["name"]] = item["updatedOn"];
      }
      setState(() {
        _isDocumentsLoaded = true;
      });
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
                      "Last updated on ${_updatedOn[title]}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? darkModeLightTextColor
                              : lightModeLightTextColor,
                          fontSize: 12),
                    ),
                    Text(
                      "By ${_updatedBy[title]}",
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
              return AddOrChangeResources(
                  addOrChange: "Change",
                  semester: widget.semester,
                  subject: widget.subject,
                  course: widget.course,
                  materialType: widget.materialType,
                  changeMaterial: title);
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
      },
    );
  }
}
