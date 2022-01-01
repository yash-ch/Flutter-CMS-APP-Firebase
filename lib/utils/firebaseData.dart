import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmseduc/authWrapper.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebaseData {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  // firebase_storage.Reference ref =
  //     firebase_storage.FirebaseStorage.instance.ref();
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

  // Future<String> svgLink(String imageName) async {
  //   String link = "";
  //   // print(imageName);
  //   link = await ref.child('svg/$imageName.svg').getDownloadURL();
  //   return link;
  // }

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

  Future<bool> memberAdmin() async {
    List nameOfTheCourses = [];
    QuerySnapshot<Map<String, dynamic>> data = await fireStore
        .collection('Members')
        .where("isAdmin", isEqualTo: true)
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

  Future<void> updateCoursesSubject(
      String courseName, bool materialOrNot, bool deleteNone) async {
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

                    if (materialOrNot) {
                      final subjectData =
                          await collectionReference("material", subject);
                      await subjectData.add(
                        CreateCollection(name: 'none'),
                      );
                    }

                    if (deleteNone) {
                      //for deleting "none" that I stored just for the reference
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
                    } //deleteNone ended
                  }
                  if (!materialOrNot) {
                    //if the subjects are present or not. if not present then updating the subjects
                    print(subjectPresentList);
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
  }

  //true for add and false for update
  Future<List> materialData(
      context,
      String addOrChangeOrNone,
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
                  await subject.reference
                      .collection("material")
                      .orderBy("updatedOn")
                      .get();
              for (var materialItem in materialReference.docs) {
                switch (addOrChangeOrNone) {
                  case "none":
                    allTheMaterial.add(materialItem.data());
                    break;
                  case "Add":
                    if (!_isAddedOrChanged) {
                      if (materialItem["name"] != materialName ||
                          materialItem["link"] != materialLink) {
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
