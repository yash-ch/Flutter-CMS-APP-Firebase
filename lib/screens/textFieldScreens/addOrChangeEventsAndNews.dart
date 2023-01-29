import 'package:cmseduc/authWrapper.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddOrChangeEventsAndNews extends StatefulWidget {
  final String whichEvents;
  final String addOrChange;
  final String changeEvent;
  const AddOrChangeEventsAndNews(
      {Key? key,
      required this.whichEvents,
      required this.addOrChange,
      required this.changeEvent})
      : super(key: key);
  @override
  _AddOrChangeEventsAndNewsState createState() =>
      _AddOrChangeEventsAndNewsState();
}

class _AddOrChangeEventsAndNewsState extends State<AddOrChangeEventsAndNews> {
  final TextEditingController _nameOfTheEvent = TextEditingController();
  final TextEditingController _websiteLinkOfTheEvent = TextEditingController();
  String _dateOfTheEvent = "";
  String _imageLinkOfTheEvent = "";

  final TextEditingController _imageLinkOfTheNews = TextEditingController();

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
          widget.addOrChange + " " + widget.whichEvents,
          style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: addOrChangeEventsAndNewsWidget(),
    );
  }

  Widget addOrChangeEventsAndNewsWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // lightTextWidget("Name of the Event"),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Container(
              width: getDeviceWidth(context) - 32,
              child: TextField(
                controller: _nameOfTheEvent,
                decoration: InputDecoration(
                  labelText: widget.whichEvents == "News"
                      ? "Headline of the news"
                      : "Event Name",
                ),
                // minLines: widget.whichEvents == "News" ? null : 1,
                maxLines: widget.whichEvents == "News" ? 3 : 1,
                keyboardType: TextInputType.multiline,
                autofocus: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: TextField(
              controller: _websiteLinkOfTheEvent,
              decoration: InputDecoration(
                labelText: "Website Link",
              ),
            ),
          ),
          widget.whichEvents == "News"
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: TextField(
                    controller: _imageLinkOfTheNews,
                    decoration: InputDecoration(
                      labelText: "Image Link",
                    ),
                  ),
                )
              : Offstage(),
          (widget.whichEvents == "Events" || widget.whichEvents == "News")
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Text(
                    "Enter Event Date",
                    style: TextStyle(
                        color: Get.isDarkMode ? Colors.white54 : Colors.black38,
                        fontSize: SmallTextSize),
                  ),
                )
              : Offstage(),
          (widget.whichEvents == "Events" || widget.whichEvents == "News")
              ? Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: () {
                        showMaterialDatePicker(
                            context: context,
                            title: "Select " + widget.whichEvents == "Events"
                                ? "Event"
                                : "News" + " Date",
                            maxLongSide: 500,
                            headerColor: Get.isDarkMode
                                ? Colors.black45
                                : selectedIconColor,
                            firstDate: widget.whichEvents == "Events"
                                ? DateTime.now()
                                : DateTime.now().subtract(Duration(days: 30)),
                            lastDate: widget.whichEvents == "Events"
                                ? DateTime.now().add(Duration(days: 90))
                                : DateTime.now(),
                            selectedDate: DateTime.now(),
                            onChanged: (value) {
                              setState(() {
                                _dateOfTheEvent =
                                    (DateFormat("dd MM yy").format(value))
                                        .toString();
                              });
                            });
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                        child: Text(
                          _dateOfTheEvent != ""
                              ? _dateOfTheEvent
                                  .toString()
                                  .replaceAll(RegExp(r' '), '/')
                              : "Select a date",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      child: Text(
                        _dateOfTheEvent == ""
                            ? "Select a dateSelect a date"
                            : _dateOfTheEvent + _dateOfTheEvent,
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Get.isDarkMode ? Colors.white30 : Colors.black26,
                          decorationThickness: 4,
                        ),
                      ),
                    ),
                  ],
                )
              : Offstage(),
          Container(
              width: double.maxFinite,
              height: 10.0,
              child: Text("- - - - " * 15)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0, 8.0),
            child: Text(
              "Please upload 4x4 size images only. " +
                  (widget.addOrChange == "Change" ? "Update" : "Upload") +
                  " screen will come after you press the upload button.",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: selectedIconColor),
                  onPressed: () {
                    _uploadOrUpdatedEvent();
                  },
                  child: widget.addOrChange == "Change"
                      ? Text("UPDATE")
                      : Text("UPLOAD")),
            ),
          ),

          widget.addOrChange == "Change"
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: selectedIconColor),
                        onPressed: () {
                          showMaterialResponsiveDialog(
                            context: context,
                            title: "Are You Sure?",
                            maxLongSide: 340.0,
                            headerColor: Get.isDarkMode
                                ? Colors.black45
                                : selectedIconColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Are you sure you want to delete \"${widget.changeEvent}\"? You won't be able to restore it.",
                                style: TextStyle(fontSize: SmallTextSize),
                              ),
                            ),
                            onConfirmed: () {
                              if (widget.whichEvents == "News") {
                                FirebaseData().managingNews(
                                    context, {}, 2, widget.changeEvent);
                              } else {
                                FirebaseData().managingEvents(
                                    context,
                                    widget.whichEvents == "Top Banners"
                                        ? "top_banners"
                                        : "all_events",
                                    {},
                                    2,
                                    widget.changeEvent);
                              }
                            },
                          );
                        },
                        child: Text("DELETE")),
                  ),
                )
              : Offstage()
        ],
      ),
    );
  }

  Future<void> _uploadOrUpdatedEvent() async {
    if (_nameOfTheEvent.text.trim() != "") {
      try {
        await http.get(Uri.parse(_websiteLinkOfTheEvent.text.trim()));

        if (widget.whichEvents == "Top Banners") {
          FirebaseData().managingEvents(
              context,
              "top_banners",
              {
                "name": _nameOfTheEvent.text.trim(),
                "link": _websiteLinkOfTheEvent.text.trim(),
                "image_link": _imageLinkOfTheEvent,
              },
              widget.addOrChange == "Add" ? 0 : 1,
              widget.changeEvent);
        } else if (widget.whichEvents == "Events") {
          if (_dateOfTheEvent != "") {
            FirebaseData().managingEvents(
                context,
                "all_events",
                {
                  "name": _nameOfTheEvent.text.trim(),
                  "link": _websiteLinkOfTheEvent.text.trim(),
                  "image_link": _imageLinkOfTheEvent,
                  "event_date": _dateOfTheEvent
                },
                widget.addOrChange == "Add" ? 0 : 1,
                widget.changeEvent);
          } else {
            Fluttertoast.showToast(
                msg: "Event date can't be left blank.",
                toastLength: Toast.LENGTH_LONG);
          }
        } else if (widget.whichEvents == "News") {
          await http.get(Uri.parse(_imageLinkOfTheNews.text.trim()));

          FirebaseData().managingNews(
              context,
              {
                "name": _nameOfTheEvent.text.trim(),
                "link": _websiteLinkOfTheEvent.text.trim(),
                "image_link": _imageLinkOfTheNews.text.trim(),
                "publish_date": _dateOfTheEvent
              },
              widget.addOrChange == "Add" ? 0 : 1,
              widget.changeEvent);
        }
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg:
                "Uploading failed. Please recheck your links.(check https:// or http:// also)",
            toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Name can't be left blank.", toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _prefillTextField() async {
    try {
      if (widget.addOrChange == "Change") {
        if (widget.whichEvents == "Top Banners") {
          List eventList = await FirebaseData().eventsData("top_banners");

          for (var event in eventList) {
            if (event["name"] == widget.changeEvent) {
              _imageLinkOfTheEvent = event["image_link"];
              _websiteLinkOfTheEvent.text = event["link"];
              _nameOfTheEvent.text = event["name"];
              setState(() {});
            }
          }
        } else if (widget.whichEvents == "Events") {
          List eventList = await FirebaseData().eventsData("all_events");

          for (var event in eventList) {
            if (event["name"] == widget.changeEvent) {
              _imageLinkOfTheEvent = event["image_link"];
              _websiteLinkOfTheEvent.text = event["link"];
              _nameOfTheEvent.text = event["name"];
              _dateOfTheEvent = event["event_date"];
              setState(() {});
            }
          }
        } else if (widget.whichEvents == "News") {
          List newsList = await FirebaseData().newsData();
          for (var news in newsList) {
            if (news["name"] == widget.changeEvent) {
              _imageLinkOfTheNews.text = news["image_link"];
              _websiteLinkOfTheEvent.text = news["link"];
              _nameOfTheEvent.text = news["name"];
              _dateOfTheEvent = news["publish_date"];
              setState(() {});
            }
          }
        }
      }
    } catch (e) {}
  }
}
