import 'package:cmseduc/authWrapper.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddOrChangeEvents extends StatefulWidget {
  final String whichEvents;
  final String addOrChange;
  final String changeEvent;
  const AddOrChangeEvents(
      {Key? key,
      required this.whichEvents,
      required this.addOrChange,
      required this.changeEvent})
      : super(key: key);
  @override
  _AddOrChangeEventsState createState() => _AddOrChangeEventsState();
}

class _AddOrChangeEventsState extends State<AddOrChangeEvents> {
  final TextEditingController _nameOfTheEvent = TextEditingController();
  // final TextEditingController _imageLinkOfTheEvent = TextEditingController();
  final TextEditingController _websiteLinkOfTheEvent = TextEditingController();
  String _dateOfTheEvent = "";
  String _imageLinkOfTheEvent = "";

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
      body: addOrChangeEventsWidget(),
    );
  }

  Widget addOrChangeEventsWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // lightTextWidget("Name of the Event"),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: TextField(
              controller: _nameOfTheEvent,
              decoration: InputDecoration(
                labelText: "Event Name",
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
          widget.whichEvents == "Events"
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
          widget.whichEvents == "Events"
              ? Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: () {
                        showMaterialDatePicker(
                            context: context,
                            title: "Select Event Date",
                            maxLongSide: 500,
                            headerColor: Get.isDarkMode
                                ? Colors.black45
                                : selectedIconColor,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
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
                              FirebaseData().managingEvents(
                                  context,
                                  widget.whichEvents == "Top Banners"
                                      ? "top_banners"
                                      : "all_events",
                                  {},
                                  2,
                                  widget.changeEvent);
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
        if (_websiteLinkOfTheEvent.text.trim().contains(
                "http://") || //for adding https if the doesn't have it
            _websiteLinkOfTheEvent.text.trim().contains("https://")) {
        } else {
          _websiteLinkOfTheEvent.text =
              "https://" + _websiteLinkOfTheEvent.text.trim();
        }

        await http.get(Uri.parse(_websiteLinkOfTheEvent.text.trim()));

        if (widget.whichEvents == "Top Banners") {
          FirebaseData().managingEvents(
              context,
              "top_banners",
              {
                "name": _nameOfTheEvent.text.trim(),
                "link": _websiteLinkOfTheEvent.text.trim(),
                "image_link": _imageLinkOfTheEvent,
                "uploadedBy": userEmail,
              },
              widget.addOrChange == "Add" ? 0 : 1,
              widget.changeEvent);
        } else {
          if (_dateOfTheEvent != "") {
            FirebaseData().managingEvents(
                context,
                "all_events",
                {
                  "name": _nameOfTheEvent.text.trim(),
                  "link": _websiteLinkOfTheEvent.text.trim(),
                  "uploadedBy": userEmail,
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
        }
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg: "Uploading failed. Please recheck your links.",
            toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Event name can't be left blank.",
          toastLength: Toast.LENGTH_LONG);
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
        } else {
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
        }
      }
    } catch (e) {}
  }
}
