import 'package:cmseduc/screens/mainScreen.dart';
import 'package:cmseduc/utils/firebaseData.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';

class ManageUsers extends StatefulWidget {
  final String addOrChange; //true for adding and false for changing
  final String
      previousUserName; //previous email address for updating the user data
  const ManageUsers(
      {Key? key, required this.addOrChange, required this.previousUserName})
      : super(key: key);

  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  bool _adminSwitch = false;
  bool _courseAccessSwitch = false;

  @override
  void initState() {
    _prefillData();
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
          widget.addOrChange + " User",
          style: Get.isDarkMode ? DarkAppBarTextStyle : LightAppBarTextStyle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: addOrChangeUser(),
    );
  }

  Widget addOrChangeUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lightTextWidget("Name of the User"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 20.0),
          child: TextField(
            controller: _userName,
            decoration: InputDecoration(
              labelText: "User Name",
            ),
          ),
        ),
        lightTextWidget("Email of the User"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 20.0),
          child: TextField(
            controller: _userEmail,
            decoration: InputDecoration(
              labelText: "User Email",
            ),
          ),
        ),
        lightTextWidget("Admin"),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Switch(
            value: _adminSwitch,
            onChanged: (value1) {
              _adminSwitch = value1;
              setState(() {});
            },
            activeColor: selectedIconColor,
            // activeTrackColor: selectedIconColor,
          ),
        ),
        lightTextWidget("Course Access"),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Switch(
            value: _courseAccessSwitch,
            onChanged: (value2) {
              _courseAccessSwitch = value2;
              setState(() {});
            },
            activeColor: selectedIconColor,
            // activeTrackColor: selectedIconColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: selectedIconColor),
                onPressed: () {
                  if (_userName.text.trim() != "" &&
                      _userEmail.text.trim() != "") {
                    FirebaseData().manageUsers(context,
                        _userEmail.text.trim(),
                        _userName.text.trim(),
                        _adminSwitch,
                        _courseAccessSwitch,
                        widget.addOrChange == "Add"? false : true,
                        widget.previousUserName);
                  } else {
                    Fluttertoast.showToast(
                        msg: "User name or email can't be left blank.",
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

  Future<void> _prefillData() async {
    if (widget.addOrChange == "Change") {
      Map userData = await FirebaseData().allUsers();
      for (var user in userData.keys) {
        if (user == widget.previousUserName) {
          _userName.text = user;
          _userEmail.text = userData[user]["email"];
          _adminSwitch = userData[user]["isAdmin"];
          _courseAccessSwitch = userData[user]["courseAccess"];
        }
      }
      setState(() {});
    }
  }
}
