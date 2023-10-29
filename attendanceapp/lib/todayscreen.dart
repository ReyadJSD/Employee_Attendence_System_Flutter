import 'dart:async';

import 'package:attendanceapp/loginscreen.dart';
import 'package:attendanceapp/main.dart';
import 'package:attendanceapp/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayScreen extends StatefulWidget {
  final String employeeId; // Add this field
  const TodayScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xffeef444c);
  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String checkInLocation = " ";
  String checkOutLocation = " ";
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  Future<void> _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lot, User.long);
    setState(() {
      location =
          "${placemark[0].street},${placemark[0].locality},${placemark[0].postalCode},${placemark[0].country}";
    });
  }

  Future<void> _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(formatDate(DateTime.now(), [dd, '-', MM, '-', yyyy]))
          .get();
      setState(() {
        User.employeeId;
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        User.employeeId=" ";
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 32),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Nexa Regular',
                      fontSize: screenWidth / 20),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _handleLogout(); // Call the logout function
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 32,left: 150),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: primary,
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Employee ${widget.employeeId}',
              style: TextStyle(
                  fontFamily: 'Nexa Bold', fontSize: screenWidth / 18),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 25),
            child: Text(
              'Todays Status',
              style: TextStyle(
                  fontFamily: 'Nexa Bold', fontSize: screenWidth / 18),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            height: 150,
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2))
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check In',
                      style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nexa Regular',
                          fontSize: screenWidth / 20),
                    ),
                    Text(
                      checkIn,
                      style: TextStyle(
                          fontFamily: 'Nexa Bold', fontSize: screenWidth / 18),
                    )
                  ],
                )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check Out',
                      style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nexa Regular',
                          fontSize: screenWidth / 20),
                    ),
                    Text(
                      checkOut,
                      style: TextStyle(
                          fontFamily: 'Nexa Bold', fontSize: screenWidth / 18),
                    )
                  ],
                ))
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                  text: DateTime.now().day.toString(),
                  style: TextStyle(
                      color: primary,
                      fontSize: screenWidth / 18,
                      fontFamily: 'Nexa Bold'),
                  children: [
                    TextSpan(
                        text: formatDate(DateTime.now(), [' ', M, '-', yyyy]),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth / 20,
                            fontFamily: 'Nexa Bold'))
                  ]),
            ),
          ),
          StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatDate(DateTime.now(), [hh, ':', nn, ':', ss, ' ', am]),
                    style: TextStyle(
                        color: Colors.black, fontSize: screenWidth / 20),
                  ),
                );
              }),
          GestureDetector(
            onTap: () async {
              if (User.lot != 0) {
                await _getLocation();

                QuerySnapshot snap = await FirebaseFirestore.instance
                    .collection("Employee")
                    .where('id', isEqualTo: User.employeeId)
                    .get();

                DocumentSnapshot snap2 = await FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(snap.docs[0].id)
                    .collection("Record")
                    .doc(formatDate(DateTime.now(), [dd, '-', MM, '-', yyyy]))
                    .get();

                try {
                  String checkIn = snap2['checkIn'];
                  setState(() {
                    checkOut =
                        formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
                  });
                  await FirebaseFirestore.instance
                      .collection("Employee")
                      .doc(snap.docs[0].id)
                      .collection("Record")
                      .doc(formatDate(DateTime.now(), [dd, '-', MM, '-', yyyy]))
                      .update({
                    'date': Timestamp.now(),
                    'checkIn': checkIn,
                    'checkOutLocation': location,
                    'checkOut':
                        formatDate(DateTime.now(), [hh, ':', nn, ' ', am]),
                  });
                } catch (e) {
                  setState(() {
                    checkIn =
                        formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
                  });
                  await FirebaseFirestore.instance
                      .collection("Employee")
                      .doc(snap.docs[0].id)
                      .collection("Record")
                      .doc(formatDate(DateTime.now(), [dd, '-', MM, '-', yyyy]))
                      .set({
                    'date': Timestamp.now(),
                    'checkIn':
                        formatDate(DateTime.now(), [hh, ':', nn, ' ', am]),
                    'checkOut': "--/--",
                    'checkInLocation': location
                  });
                }
              } else {
                Timer(Duration(seconds: 3), () async {
                  await _getLocation();
                  QuerySnapshot snap = await FirebaseFirestore.instance
                      .collection("Employee")
                      .where('id', isEqualTo: User.employeeId)
                      .get();

                  DocumentSnapshot snap2 = await FirebaseFirestore.instance
                      .collection("Employee")
                      .doc(snap.docs[0].id)
                      .collection("Record")
                      .doc(formatDate(DateTime.now(), [dd, '-', MM, '-', yyyy]))
                      .get();

                  try {
                    String checkIn = snap2['checkIn'];
                    setState(() {
                      checkOut =
                          formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
                    });
                    await FirebaseFirestore.instance
                        .collection("Employee")
                        .doc(snap.docs[0].id)
                        .collection("Record")
                        .doc(formatDate(
                            DateTime.now(), [dd, '-', MM, '-', yyyy]))
                        .update({
                      'date': Timestamp.now(),
                      'checkIn': checkIn,
                      'checkOutLocation': location,
                      'checkOut': formatDate(DateTime.now(), [hh, ':', nn, ' ', am]),
                    });
                  } catch (e) {
                    setState(() {
                      checkIn = formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
                    });
                    await FirebaseFirestore.instance
                        .collection("Employee")
                        .doc(snap.docs[0].id)
                        .collection("Record")
                        .doc(formatDate(
                            DateTime.now(), [dd, '-', MM, '-', yyyy]))
                        .set({
                      'date': Timestamp.now(),
                      'checkIn':
                          formatDate(DateTime.now(), [hh, ':', nn, ' ', am]),
                      'checkOut': "--/--",
                      'checkInLocation': location
                    });
                  }
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              height: 90,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(2, 2))
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: checkOut == "--/--"
                          ? Container(
                              height: 60,
                              width: screenWidth,
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30))),
                              child: Center(
                                child: Text(
                                  checkIn == "--/--" ? "Check In" : "Check Out",
                                  style: TextStyle(
                                      fontSize: screenWidth / 16,
                                      fontFamily: "Nexa Bold",
                                      color: Colors.white,
                                      letterSpacing: 2),
                                ),
                              ),
                            )
                          : Container(
                              child: Center(
                                child: Text(
                                  'You have completed this day',
                                  style: TextStyle(
                                      fontSize: screenWidth / 24,
                                      fontFamily: "Nexa Bold",
                                      color: Colors.black,
                                      letterSpacing: 2),
                                ),
                              ),
                            )),
                ],
              ),
            ),
          ),
          location != " "
              ? Text(
                  'Location: $location',
                  style: TextStyle(
                      fontFamily: 'Nexa Regular', fontSize: screenWidth / 20),
                )
              : const SizedBox(),
        ],
      ),
    ));
  }

// Function to handle logout
  void _handleLogout() async {
    // Clear user session
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('employeeId').then((_){
      Navigator.push(context, MaterialPageRoute(builder: (context) => AuthCheck(),));
    });
  }
}
