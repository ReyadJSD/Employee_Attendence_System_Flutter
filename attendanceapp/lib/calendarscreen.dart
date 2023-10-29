import 'package:attendanceapp/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xffeef444c);
  String _month = DateFormat('MMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 32),
              child: Text(
                'My Attendance',
                style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: screenWidth / 18,
                  color: Colors.black26,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 22),
                  child: Text(
                    _month,
                    style: TextStyle(
                      fontFamily: 'Nexa Bold',
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 32),
                    child: GestureDetector(
                      onTap: () async{
                        final month = await showMonthYearPicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2099)
                        );
                        if(month != null){
                          setState(() {
                            _month = DateFormat('MMM').format(month);
                          });
                        }
                      },
                      child: Text(
                        'Pick a Month',
                        style: TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: screenHeight / 1.45,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Employee")
                    .doc(User.id)
                    .collection("Record")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: snap.length,
                      itemBuilder: (context, index) {
                        final data = snap[index].data() as Map<String, dynamic>?; // Cast data to Map<String, dynamic> or null
                        final checkIn = data?['checkIn'];
                        final checkOut = data?['checkOut'];

                        final date = data?['date']?.toDate(); // Check if 'date' field exists and convert it to a DateTime
                        return DateFormat('MMM').format(snap[index]['date'].toDate()) == _month ?
                        Container(
                          margin: const EdgeInsets.only(top: 12, left: 6, right: 6),
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              )
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      date != null
                                          ? DateFormat('EE\n dd').format(date)
                                          : 'N/A', // Check if 'date' is not null before formatting it
                                      style: TextStyle(
                                        fontSize: screenWidth / 18,
                                        fontFamily: 'Nexa Bold',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'Nexa Regular',
                                          fontSize: screenWidth / 20),
                                    ),
                                    Text(
                                      checkIn ?? 'N/A',
                                      style: TextStyle(
                                          fontFamily: 'Nexa Bold',
                                          fontSize: screenWidth / 18),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Check Out',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'Nexa Regular',
                                          fontSize: screenWidth / 20),
                                    ),
                                    Text(
                                      checkOut ?? 'N/A',
                                      style: TextStyle(
                                          fontFamily: 'Nexa Bold',
                                          fontSize: screenWidth / 18),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ): const SizedBox();
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
