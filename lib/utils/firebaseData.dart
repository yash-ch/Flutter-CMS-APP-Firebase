import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmseduc/authWrapper.dart';
import 'package:cmseduc/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseData {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Future<List> courses() async {
    List nameOfTheCourses = [];
    QuerySnapshot<Map<String, dynamic>> data = await fireStore
        .collection('Courses')
        .where("active", isEqualTo: true)
        .get();
    for (var item in data.docs) {
      nameOfTheCourses.add(item["name"]);
    }
    return nameOfTheCourses;
  }

  Future<List> materialType() async {
    List materialTypeList = [];
    QuerySnapshot<Map<String, dynamic>> data =
        await fireStore.collection('MaterialType').orderBy("name").get();
    for (var item in data.docs) {
      materialTypeList.add(item["name"]);
    }
    return materialTypeList;
  }

  Future<List> subjectsOfCourse(String courseName, int sem) async {
    List subjectList = [];
    List rawSubjectList = [];
    QuerySnapshot<Map<String, dynamic>> courseData = await fireStore
        .collection('Courses')
        .where("name", isEqualTo: courseName)
        .get();
    for (var subject in courseData.docs) {
      rawSubjectList = subject["sem$sem"];
    }
    for (var subject in rawSubjectList) {
      if (subject != "") {
        subjectList.add(subject);
      }
    }
    // print(subjectList);
    return subjectList;
  }

  Future<List> uploadByAndAt(String courseName) async {
    List uploadByAt = [];
    QuerySnapshot<Map<String, dynamic>> courseData = await fireStore
        .collection('Courses')
        .where("name", isEqualTo: courseName)
        .get();
    for (var item in courseData.docs) {
      uploadByAt = [item["uploadAt"], item["uploadBy"]];
    }

    return uploadByAt;
  }

  Future<void> addOrChangeCourse(
      context,
      bool addOrChange, //true for add
      String changeCourseName,
      String courseName,
      List sem1List,
      List sem2List,
      List sem3List,
      List sem4List,
      List sem5List,
      List sem6List) async {
    List presentCourses = await courses();
    if (presentCourses.contains(courseName) && addOrChange) {
      Fluttertoast.showToast(
          msg: "Course is already present in the database.",
          toastLength: Toast.LENGTH_LONG);
    } else {
      try {
        if (addOrChange) {
          await fireStore.collection('Courses').add({
            "name": courseName,
            "active": true,
            "sem1": sem1List,
            "sem2": sem2List,
            "sem3": sem3List,
            "sem4": sem4List,
            "sem5": sem5List,
            "sem6": sem6List,
            "uploadBy": userEmail,
            "uploadAt":
                "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
          });
        } else {
          QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
              await fireStore //for gathering id of the document of course
                  .collection("Courses")
                  .where("name", isEqualTo: changeCourseName)
                  .get();
          dynamic documentId = "";
          for (var item in docuIdSnapshot.docs) {
            documentId = item.id;
          }
          await fireStore.collection('Courses').doc(documentId).update({
            "name": courseName,
            "active": true,
            "sem1": sem1List,
            "sem2": sem2List,
            "sem3": sem3List,
            "sem4": sem4List,
            "sem5": sem5List,
            "sem6": sem6List,
            "uploadBy": userEmail,
            "uploadAt":
                "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
          });
        }

        Fluttertoast.showToast(
            msg: "Course was successfully " +
                (addOrChange ? "uploaded." : "updated."));
        Navigator.of(context).pop();
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(
            msg: (e.message).toString(), toastLength: Toast.LENGTH_LONG);
      }
    }
  }

  Future<Map> subjectMapOfCourse(String courseName) async {
    Map subjectListPerSem = {};

    QuerySnapshot<Map<String, dynamic>> courseData = await fireStore
        .collection('Courses')
        .where("name", isEqualTo: courseName)
        .get();
    for (var i = 1; i < 7; i++) {
      for (var item in courseData.docs) {
        subjectListPerSem["sem$i"] = item["sem$i"];
      }
    }
    // print(subjectListPerSem);
    return subjectListPerSem;
  }

  // funtion for adding semester no and course into database
  // Future<void> addingSemesterNoAndCourse(
  //     String materialType, String courseName, bool addSemOrRest) async {
  //   //true for adding sem
  //   QuerySnapshot<Map<String, dynamic>> materialTypeRef =
  //       await FirebaseFirestore.instance
  //           .collection('MaterialType')
  //           .where("name", isEqualTo: materialType)
  //           .get();
  //   // print(materialTypeRef.docs.length);
  //   for (var material in materialTypeRef.docs) {
  //     //for adding semester nos
  //     if (addSemOrRest) {
  //       final materialTypeData = collectionReference("semester", material);
  //       for (var i = 1; i < 7; i++) {
  //         print(i);
  //         //for adding semester nos
  //         await materialTypeData.add(
  //           CreateCollection(name: 'sem$i'),
  //         );
  //       }
  //     } else {
  //       for (var i = 1; i < 7; i++) {
  //         print(i);

  //         QuerySnapshot<Map<String, dynamic>> semesterDataRef =
  //             await navigateIntoCollection(material, "semester", "sem$i");

  //         for (var sem in semesterDataRef.docs) {
  //           final semData = collectionReference("course", sem);
  //           await semData.add(
  //             CreateCollection(name: courseName),
  //           );
  //           QuerySnapshot<Map<String, dynamic>> courseDataRef =
  //               await navigateIntoCollection(sem, "course", courseName);

  //           for (var course in courseDataRef.docs) {
  //             final courseData = collectionReference("subject", course);
  //             await courseData.add(
  //               CreateCollection(name: 'none'),
  //             );
  //             QuerySnapshot<Map<String, dynamic>> subjectDataRef =
  //                 await navigateIntoCollection(course, "subject", "none");

  //             for (var subject in subjectDataRef.docs) {
  //               final subjectData =
  //                   await collectionReference("material", subject);
  //               await subjectData.add(
  //                 CreateCollection(name: 'none'),
  //               );
  //             }
  //           }
  //         }
  //         if (i == 6) {
  //           print("done");
  //           break;
  //         }
  //       }
  //     }
  //     break;
  //   }
  // }

//for navigate to a collection
  navigateIntoCollection(
      QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      String title,
      String equalToName) {
    return documentSnapshot.reference
        .collection(title)
        .where("name", isEqualTo: equalToName)
        .get();
  }

//for addingcollection() function
  collectionReference(
      String name, QueryDocumentSnapshot<Map<String, dynamic>> snapshotData) {
    return snapshotData.reference
        .collection(name)
        .withConverter<CreateCollection>(
          fromFirestore: (snapshot, _) =>
              CreateCollection.fromJson(snapshot.data()!),
          toFirestore: (createCollection, _) => createCollection.toJson(),
        );
  }

  Future<void> updateCoursesSubject(String courseName) async {
    List materialTypeList = await materialType();
    QuerySnapshot<Map<String, dynamic>> materialTypedata =
        await fireStore.collection('MaterialType').get();

    for (var material in materialTypedata.docs) {
      for (var mat in materialTypeList) {
        if (mat == material.data()["name"]) {
          QuerySnapshot<Map<String, dynamic>> semesterReference =
              await material.reference.collection("semester").get();

          for (var semester in semesterReference.docs) {
            for (var i = 1; i < 7; i++) {
              //for different semester
              if (semester.data()["name"] == "sem$i") {
                List subjectsOfCourseList =
                    await subjectsOfCourse(courseName, i);

                QuerySnapshot<Map<String, dynamic>> courseReference =
                    await navigateIntoCollection(
                        semester, "course", courseName);

                for (var course in courseReference.docs) {
                  QuerySnapshot<Map<String, dynamic>> subjectReference =
                      await course.reference.collection("subject").get();

                  List subjectPresentList = [];
                  for (var subject in subjectReference.docs) {
                    subjectPresentList.add(subject.data()["name"]);
                    print("processing");
                    if (subject.data()["name"] == "none") {
                      await course.reference
                          .collection("subject")
                          .doc(subject.id)
                          .delete();
                    }
                    QuerySnapshot<Map<String, dynamic>> materialReference =
                        await subject.reference.collection("material").get();

                    for (var materialItem in materialReference.docs) {
                      if (materialItem.data()["name"] == "none") {
                        await subject.reference
                            .collection("material")
                            .doc(materialItem.id)
                            .delete();
                      }
                    }

                    final subjectData =
                        await collectionReference("material", subject);
                    await subjectData.add(
                      CreateCollection(name: 'none'),
                    );
                  }
                  for (var item in subjectsOfCourseList) {
                    if (!subjectPresentList.contains(item)) {
                      await course.reference
                          .collection("subject")
                          .add({"name": item});
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //true for add and false for update
  Future<List> materialData(
      context,
      String addOrChangeOrDelete,
      String changeMaterialName,
      String courseName,
      String materialType,
      String subjectName,
      int sem,
      String materialName,
      String materialLink) async {
    List allTheMaterial = [];

    QuerySnapshot<Map<String, dynamic>> materialTypedata = await fireStore
        .collection('MaterialType')
        .where("name", isEqualTo: materialType)
        .get();
    bool _isAddedOrChanged = false;
    try {
      for (var material in materialTypedata.docs) {
        QuerySnapshot<Map<String, dynamic>> semesterReference =
            await navigateIntoCollection(material, "semester", "sem$sem");

        for (var semester in semesterReference.docs) {
          QuerySnapshot<Map<String, dynamic>> courseReference =
              await navigateIntoCollection(semester, "course", courseName);

          for (var course in courseReference.docs) {
            QuerySnapshot<Map<String, dynamic>> subjectReference =
                await navigateIntoCollection(course, "subject", subjectName);

            for (var subject in subjectReference.docs) {
              QuerySnapshot<Map<String, dynamic>> materialReference =
                  await subject.reference.collection("material").get();
              for (var materialItem in materialReference.docs) {
                switch (addOrChangeOrDelete) {
                  case "none":
                    if (materialItem["name"] != "none") {
                      allTheMaterial.add(materialItem.data());
                    }
                    break;
                  case "Add":
                    if (!_isAddedOrChanged) {
                      if (materialItem["name"] != materialName ||
                          materialItem["link"] != materialLink) {
                        Fluttertoast.showToast(msg: "Please wait, processing.");
                        subject.reference.collection("material").add({
                          "name": materialName,
                          "link": materialLink,
                          "updatedBy": userEmail,
                          "updatedOn":
                              "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
                        });
                        _isAddedOrChanged = true;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Course is already present in the database.",
                            toastLength: Toast.LENGTH_LONG);
                      }
                      Fluttertoast.showToast(
                          msg: "$materialType was successfully uploaded.");
                      Navigator.of(context).pop();
                    }
                    break;
                  case "Change":
                    if (!_isAddedOrChanged) {
                      QuerySnapshot<
                          Map<String,
                              dynamic>> docuIdSnapshot = await subject
                          .reference //for gathering id of the document of course
                          .collection("material")
                          .where("name", isEqualTo: changeMaterialName)
                          .get();
                      for (var item in docuIdSnapshot.docs) {
                        Fluttertoast.showToast(msg: "Please wait, processing.");
                        await subject.reference
                            .collection("material")
                            .doc(item.id)
                            .update({
                          "name": materialName,
                          "link": materialLink,
                          "updatedBy": userEmail,
                          "updatedOn":
                              "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
                        });
                        _isAddedOrChanged = true;

                        Fluttertoast.showToast(
                            msg: "$materialType was successfully updated.");
                        Navigator.of(context).pop();

                        break;
                      }
                    }
                    break;
                  case "Delete":
                    QuerySnapshot<
                        Map<String,
                            dynamic>> docuIdSnapshot = await subject
                        .reference //for gathering id of the document of course
                        .collection("material")
                        .where("name", isEqualTo: changeMaterialName)
                        .get();
                    for (var item in docuIdSnapshot.docs) {
                      Fluttertoast.showToast(msg: "Please wait, processing.");
                      await subject.reference
                          .collection("material")
                          .doc(item.id)
                          .delete();
                      _isAddedOrChanged = true;

                      Fluttertoast.showToast(
                          msg: "$materialType was successfully Deleted.");
                      Navigator.of(context).pop();
                    }
                }
              }
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
    // print(allTheMaterial);
    return allTheMaterial;
  }

  Future<List> aeccGESubjects(int sem, String aeccOrGE) async {
    List subjectList = [];
    //for returning AECC or GE subjects
    QuerySnapshot<Map<String, dynamic>> materialTypedata = await fireStore
        .collection('MaterialType')
        .where("name", isEqualTo: "Timetable")
        .get();
    try {
      for (var materialType in materialTypedata.docs) {
        QuerySnapshot<Map<String, dynamic>> semesterReference =
            await navigateIntoCollection(materialType, "semester", "sem$sem");
        for (var semester in semesterReference.docs) {
          QuerySnapshot<Map<String, dynamic>> subjectReference =
              await semester.reference.collection(aeccOrGE).get();
          for (var subject in subjectReference.docs) {
            if (subject["name"] != "none") {
              subjectList.add(subject["name"]);
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
    return subjectList;
  }

  Future<void> manageAeccOrGESubjects(int sem, String aeccOrGE,
      String subjectName, int addOrChangeOrDelete, String previousName) async {
    //0 for add , 1 for change, 2 for delete
    QuerySnapshot<Map<String, dynamic>> materialTypedata =
        await fireStore.collection('MaterialType').get();
    try {
      for (var material in materialTypedata.docs) {
        QuerySnapshot<Map<String, dynamic>> semesterReference =
            await navigateIntoCollection(material, "semester", "sem$sem");
        for (var semester in semesterReference.docs) {
          if (addOrChangeOrDelete == 0) {
            await semester.reference
                .collection(aeccOrGE)
                .add({"name": subjectName});
            QuerySnapshot<Map<String, dynamic>> aeccOrGeReference =
                await semester.reference
                    .collection(aeccOrGE)
                    .where(subjectName)
                    .get();
            for (var materialItem in aeccOrGeReference.docs) {
              if (materialItem["name"] == subjectName) {
                final semData = collectionReference("material", materialItem);
                await semData.add(
                  CreateCollection(name: "none"),
                );
              }
            }
          } else {
            QuerySnapshot<Map<String, dynamic>> subjectReference =
                await navigateIntoCollection(semester, aeccOrGE, previousName);
            for (var subject in subjectReference.docs) {
              if (addOrChangeOrDelete == 1) {
                await semester.reference
                    .collection(aeccOrGE)
                    .doc(subject.id)
                    .update({"name": subjectName});
              } else if (addOrChangeOrDelete == 2) {
                await semester.reference
                    .collection(aeccOrGE)
                    .doc(subject.id)
                    .delete();
              }
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future<List> aeccOrGEData(
      context,
      int sem,
      String aeccOrGE,
      String materialType,
      String subjectName,
      int addOrChangeOrDelete,
      String changeMaterial, //0 - return data, 1- data, 2-change, 3-delete
      Map<String, dynamic> dataMap) async {
    List materialList = [];
    List nameList = [];
    QuerySnapshot<Map<String, dynamic>> materialTypedata = await fireStore
        .collection('MaterialType')
        .where("name", isEqualTo: materialType)
        .get();

    try {
      for (var material in materialTypedata.docs) {
        QuerySnapshot<Map<String, dynamic>> semesterReference =
            await navigateIntoCollection(material, "semester", "sem$sem");
        for (var semester in semesterReference.docs) {
          QuerySnapshot<Map<String, dynamic>> subjectReference =
              await navigateIntoCollection(semester, aeccOrGE, subjectName);
          for (var subject in subjectReference.docs) {
            QuerySnapshot<Map<String, dynamic>> materialReference =
                await subject.reference.collection("material").get();
            for (var material in materialReference.docs) {
              if (material["name"] != "none") {
                nameList.add(material["name"]);
              }
            }
            if (addOrChangeOrDelete == 1) {
              if (nameList.contains(dataMap["name"])) {
                Fluttertoast.showToast(
                    msg: "$materialType is already present in the database.");
              } else {
                Fluttertoast.showToast(msg: "Please wait, processing.");
                //add
                await subject.reference.collection("material").add({
                  "link": dataMap["link"],
                  "name": dataMap["name"],
                  "updatedBy": userEmail,
                  "updatedOn":
                      "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
                });
                Fluttertoast.showToast(
                    msg: "$materialType was successfully uploaded.");
                Navigator.of(context).pop();
              }
            } else if (addOrChangeOrDelete == 0) {
              QuerySnapshot<Map<String, dynamic>> materialReference =
                  await subject.reference.collection("material").get();
              for (var material in materialReference.docs) {
                if (material["name"] != "none") {
                  materialList.add(material.data());
                }
              }
            } else {
              QuerySnapshot<Map<String, dynamic>> materialReference =
                  await navigateIntoCollection(
                      subject, "material", changeMaterial);

              for (var material in materialReference.docs) {
                switch (addOrChangeOrDelete) {
                  case 2:
                    Fluttertoast.showToast(msg: "Please wait, processing.");
                    await subject.reference
                        .collection("material")
                        .doc(material.id)
                        .update(dataMap);
                    Fluttertoast.showToast(
                        msg: "$materialType was successfully updated.");
                    Navigator.of(context).pop();

                    break;
                  case 3:
                    Fluttertoast.showToast(msg: "Please wait, processing.");
                    await subject.reference
                        .collection("material")
                        .doc(material.id)
                        .delete();
                    Fluttertoast.showToast(
                        msg: "$materialType was successfully deleted.");
                    Navigator.of(context).pop();
                    break;
                }
                break;
              }
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
    return materialList;
  }

  Future<Map> allUsers() async {
    Map users = {};
    QuerySnapshot<Map<String, dynamic>> data =
        await fireStore.collection('Members').get();
    for (var item in data.docs) {
      users[item["name"]] = {
        "email": item["email"],
        "isAdmin": item["isAdmin"],
        "courseAccess": item["courseAccess"]
      };
    }
    return users;
  }

  Future<bool> userRole(String role) async {
    List nameOfTheCourses = [];
    QuerySnapshot<Map<String, dynamic>> data = await fireStore
        .collection('Members')
        .where(role, isEqualTo: true)
        .get();
    for (var item in data.docs) {
      nameOfTheCourses.add(item["email"]);
    }
    if (nameOfTheCourses.contains(userEmail)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> manageUsers(
      context,
      String userEmailId,
      String userName,
      bool isAdmin,
      bool courseAccess,
      bool addOrChange,
      String previousName) async {
    //true for changing
    Map users = await allUsers();
    List usersEmailList = [];
    for (var email in users.values) {
      usersEmailList.add(email);
    }
    if (usersEmailList.contains(userEmailId) && !addOrChange) {
      Fluttertoast.showToast(
          msg: "User is already present in the database.",
          toastLength: Toast.LENGTH_LONG);
    } else {
      if (!addOrChange) {
        await fireStore.collection('Members').add({
          "email": userEmailId,
          "name": userName,
          "isAdmin": isAdmin,
          "courseAccess": courseAccess
        });
      } else {
        QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
            await fireStore //for gathering id of the document of course
                .collection("Members")
                .where("name", isEqualTo: previousName)
                .get();
        for (var item in docuIdSnapshot.docs) {
          await fireStore.collection('Members').doc(item.id).update({
            "email": userEmailId,
            "name": userName,
            "isAdmin": isAdmin,
            "courseAccess": courseAccess
          });
          break;
        }
      }
    }
    Fluttertoast.showToast(
        msg: "User was successfully " + (!addOrChange ? "added." : "updated."));
    Navigator.of(context).pop();
  }

  Future<List> eventsData(String eventType) async {
    List allTheMaterial = [];

    QuerySnapshot<Map<String, dynamic>> eventData = await fireStore
        .collection('HomePage')
        .where("name", isEqualTo: eventType)
        .get();

    for (var event in eventData.docs) {
      QuerySnapshot<Map<String, dynamic>> postsReference =
          await event.reference.collection("Posts").get();

      for (var post in postsReference.docs) {
        allTheMaterial.add(post.data());
      }
    }
    return allTheMaterial;
  }

  //for events
  Future<void> managingEvents(context, String eventType, Map data,
      int addOrChangeOrDelete, String previousName) async {
    print(data);
    //0 for add, 1 for change  and 2 delete
    //true for add
    List _eventsNames = [];
    List _eventsDataList = await eventsData(eventType);
    String _imageLink = "";
    bool _uploadNewImage = false; // for uploading new image in change screen
    for (var post in _eventsDataList) {
      _eventsNames.add(post["name"]);
    }
    if (_eventsNames.contains(data["name"]) && addOrChangeOrDelete == 0) {
      Fluttertoast.showToast(
          msg: "Same name event is already present in the database.",
          toastLength: Toast.LENGTH_SHORT);
    } else {
      if (addOrChangeOrDelete == 0) {
        _imageLink =
            await _uploadImageAndReturnLink(eventType, data["name"], false);
      } else if (addOrChangeOrDelete == 1) {
        await showMaterialResponsiveDialog(
            context: context,
            title: "Event Image",
            headerColor: Get.isDarkMode ? Colors.black45 : selectedIconColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        child: Image.network(
                          data["image_link"],
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Text("Do you want to upload a new image?"),
                  )
                ],
              ),
            ),
            confirmText: "Yes",
            cancelText: "No",
            onConfirmed: () {
              _uploadNewImage = true;
            });
        if (_uploadNewImage) {
          _imageLink =
              await _uploadImageAndReturnLink(eventType, data["name"], false);
        } else {
          _imageLink = data["image_link"];
        }
      }

      if (_imageLink == "" &&
          (addOrChangeOrDelete == 0 || addOrChangeOrDelete == 1)) {
        Fluttertoast.showToast(
            msg: "No image was uploaded. Please Upload image to continue.");
      } else {
        QuerySnapshot<Map<String, dynamic>> eventData = await fireStore
            .collection('HomePage')
            .where("name", isEqualTo: eventType)
            .get();

        for (var event in eventData.docs) {
          CollectionReference<Map<String, dynamic>> postsReference =
              event.reference.collection("Posts");
          switch (addOrChangeOrDelete) {
            case 0:
              if (eventType == "top_banners") {
                postsReference.add({
                  "name": data["name"],
                  "image_link": _imageLink,
                  "link": data["link"],
                  "uploadedBy": userEmail,
                  "uploadedOn":
                      "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
                });
              } else {
                postsReference.add({
                  "name": data["name"],
                  "image_link": _imageLink,
                  "link": data["link"],
                  "uploadedBy": userEmail,
                  "uploadedOn":
                      "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}",
                  "event_date": data["event_date"]
                });
              }
              Fluttertoast.showToast(
                  msg: "Event was successfully added.",
                  toastLength: Toast.LENGTH_LONG);

              break;
            case 1:
              QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
                  await postsReference
                      .where("name", isEqualTo: previousName)
                      .get();
              for (var item in docuIdSnapshot.docs) {
                if (eventType == "top_banners") {
                  await postsReference.doc(item.id).update({
                    "name": data["name"],
                    "image_link": data["image_link"],
                    "link": data["link"],
                    "uploadedBy": userEmail,
                    "uploadedOn":
                        "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
                  });
                } else {
                  await postsReference.doc(item.id).update({
                    "name": data["name"],
                    "image_link": data["image_link"],
                    "link": data["link"],
                    "uploadedBy": userEmail,
                    "uploadedOn":
                        "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}",
                    "event_date": data["event_date"]
                  });
                }
                Fluttertoast.showToast(
                    msg: "Event was successfully updated.",
                    toastLength: Toast.LENGTH_LONG);
                break;
              }
              break;
            case 2: //for deleting event
              QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
                  await postsReference
                      .where("name", isEqualTo: previousName)
                      .get();
              for (var item in docuIdSnapshot.docs) {
                await _deleteImage("images/$eventType/$previousName");
                await postsReference.doc(item.id).delete();
                Fluttertoast.showToast(
                    msg: "Event was successfully deleted.",
                    toastLength: Toast.LENGTH_LONG);
                break;
              }
              break;
          }
        }
      }

      Navigator.of(context).pop();
    }
  }

  //for events
  Future<String> _uploadImageAndReturnLink(
      String whichEvent, String imageName, bool returnImageOrDoBoth) async {
    try {
      print(imageName);
      //true for returning image
      Reference reference =
          FirebaseStorage.instance.ref().child("images/$whichEvent/$imageName");
      if (!returnImageOrDoBoth) {
        Fluttertoast.showToast(
            msg: "Select file for the event.", toastLength: Toast.LENGTH_LONG);
        ImagePicker _picker = ImagePicker();
        // Pick an image
        XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        File imageFile = File(image!.path);
        Fluttertoast.showToast(
            msg: "Please wait file is uploading. Don't exit now.",
            toastLength: Toast.LENGTH_SHORT);
        await reference.putFile(imageFile);
      }

      String link = "";
      link = await reference.getDownloadURL();
      return link;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Something went wrong.", toastLength: Toast.LENGTH_LONG);
      return "";
    }
  }

  //for events
  Future<void> _deleteImage(String imageLocation) async {
    try {
      Fluttertoast.showToast(
          msg: "Please wait file is deleting. Don't exit now.",
          toastLength: Toast.LENGTH_SHORT);
      Reference reference = FirebaseStorage.instance.ref().child(imageLocation);
      await reference.delete();
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong.", toastLength: Toast.LENGTH_SHORT);
    }
  }

  // Future<List> newsData(bool initialOrWhole) async {
  //   //will load only some news in initial (intial == true)|(whole data == false)
  //   List allTheMaterial = [];

  //   QuerySnapshot<Map<String, dynamic>> eventData = await fireStore
  //       .collection('HomePage')
  //       .where("name", isEqualTo: "news")
  //       .get();

  //   for (var event in eventData.docs) {
  //     if (initialOrWhole) {
  //       QuerySnapshot<Map<String, dynamic>> postsReference =
  //           await event.reference.collection("Posts").limit(10).get();

  //       for (var post in postsReference.docs) {
  //         allTheMaterial.add(post.data());
  //       }
  //     } else {
  //       QuerySnapshot<Map<String, dynamic>> postsReference =
  //           await event.reference.collection("Posts").get();

  //       for (var post in postsReference.docs) {
  //         allTheMaterial.add(post.data());
  //       }
  //     }
  //   }
  //   return allTheMaterial;
  // }

  Future<List> newsData() async {
    List allTheMaterial = [];

    QuerySnapshot<Map<String, dynamic>> eventData = await fireStore
        .collection('HomePage')
        .where("name", isEqualTo: "news")
        .get();

    for (var event in eventData.docs) {
      QuerySnapshot<Map<String, dynamic>> postsReference =
          await event.reference.collection("Posts").get();

      for (var post in postsReference.docs) {
        allTheMaterial.add(post.data());
      }
    }
    return allTheMaterial;
  }

  Future<void> managingNews(
      context, Map data, int addOrChangeOrDelete, String previousName) async {
    List _newsNames = [];
    List _newsDataList = await newsData();
    for (var post in _newsDataList) {
      _newsNames.add(post["name"]);
    }
    if (_newsNames.contains(data["name"]) && addOrChangeOrDelete == 0) {
      Fluttertoast.showToast(
          msg: "Same headline news is already present in the database.",
          toastLength: Toast.LENGTH_SHORT);
    } else {
      QuerySnapshot<Map<String, dynamic>> eventData = await fireStore
          .collection('HomePage')
          .where("name", isEqualTo: "news")
          .get();

      for (var event in eventData.docs) {
        CollectionReference<Map<String, dynamic>> postsReference =
            event.reference.collection("Posts");
        switch (addOrChangeOrDelete) {
          case 0:
            postsReference.add({
              "name": data["name"],
              "image_link": data["image_link"],
              "link": data["link"],
              "uploadedBy": userEmail,
              "uploadedOn":
                  "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
            });
            Fluttertoast.showToast(
                msg: "News was successfully added.",
                toastLength: Toast.LENGTH_LONG);

            break;
          case 1:
            QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
                await postsReference
                    .where("name", isEqualTo: previousName)
                    .get();
            for (var item in docuIdSnapshot.docs) {
              await postsReference.doc(item.id).update({
                "name": data["name"],
                "image_link": data["image_link"],
                "link": data["link"],
                "uploadedBy": userEmail,
                "uploadedOn":
                    "${DateTime.now().day} ${DateFormat("MMMM").format(DateTime.now())} ${DateTime.now().year} at ${DateFormat("jm").format(DateTime.now())}"
              });
              Fluttertoast.showToast(
                  msg: "News was successfully updated.",
                  toastLength: Toast.LENGTH_LONG);
              break;
            }
            break;
          case 2: //for deleting event
            QuerySnapshot<Map<String, dynamic>> docuIdSnapshot =
                await postsReference
                    .where("name", isEqualTo: previousName)
                    .get();
            for (var item in docuIdSnapshot.docs) {
              await _deleteImage("images/news/$previousName");
              await postsReference.doc(item.id).delete();
              Fluttertoast.showToast(
                  msg: "News was successfully deleted.",
                  toastLength: Toast.LENGTH_LONG);
              break;
            }
            break;
        }
      }

      Navigator.of(context).pop();
    }
  }
}

class CreateCollection {
  CreateCollection({required this.name});

  CreateCollection.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          // genre: json['genre']! as String,
        );

  final String name;
  // final String genre;

  Map<String, Object?> toJson() {
    return {
      'name': name,
    };
  }
}
