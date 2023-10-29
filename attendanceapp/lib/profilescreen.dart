

import 'package:attendanceapp/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String birth = 'Date of Birth';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void picUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 90
    );
    Reference ref = FirebaseStorage.instance.ref().child("${User.employeeId.toLowerCase()}_profilePic.jpg");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePicLinc = value;
      });
      await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
        'profilePic': value,
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                picUploadProfilePic();
              },
              child: Container(
                margin: EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary
                ),
                child: Center(
                    child: User.profilePicLinc == " " ? const Icon(
                        Icons.person,
                      color: Colors.white,
                      size: 80,
                    ) : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                            User.profilePicLinc,
                          fit: BoxFit.cover, // Set the fit property to BoxFit.cover
                          width: double.infinity,
                          height: double.infinity,
                        )
                    ),
                ),
              ),
            ),
            Align(
              child: Text(
                "Employee ${User.employeeId}",
                style:TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: 18
                ),
              ),
            ),
            const SizedBox(height: 24),
            User.conEdit ? textField('First Name', 'First Name', firstNameController) : field('First Name', User.firstName),
            User.conEdit ? textField('Last Name', 'Last Name', lastNameController) : field('Last Name', User.lastName),

            User.conEdit ? GestureDetector(
              onTap: (){
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  builder: (context, child){
                      return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                                primary: primary,
                                secondary: primary,
                                onSecondary: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                primary: primary
                              ),
                            ),
                            textTheme: const TextTheme(
                              headline4: TextStyle(
                                fontFamily: 'Nexa Bold'
                            ),
                          ),
                          ),
                          child: child!
                      );
                  }
                ).then((value){
                  setState(() {
                    birth = DateFormat('MM/dd/yyy').format(value!);
                  });
                });
              },
              child: field("Date of Birth", birth)
            ): field('Date of Birth', User.birthDate),
            User.conEdit ? textField('Address', 'Address', addressController) : field('Address', User.address),
            User.conEdit ? GestureDetector(
              onTap: () async{
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String birthDate = birth;
                String address = addressController.text;
                if(User.conEdit){
                  if(firstName.isEmpty){
                    showSnackBar('Enter your first name');
                  }else if(lastName.isEmpty){
                    showSnackBar('Enter your last name');
                  }else if(birthDate.isEmpty){
                    showSnackBar('Enter your birth date');
                  }else if(address.isEmpty){
                    showSnackBar('Enter your address');
                  }else{
                    await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
                      'firstName' : firstName,
                      'lastName' : lastName,
                      'birthDate' : birthDate,
                      'address' : address,
                      'conEdit' :false
                    }).then((value){
                        setState(() {
                          User.conEdit = false;
                          User.firstName = firstName;
                          User.lastName = lastName;
                          User.birthDate = birthDate;
                          User.address = address;
                        });
                    });
                  }
                } else{
                  showSnackBar('You can\'t edit employee, Please contact support team');
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.only(left: 11),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  color: primary
                ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                          fontFamily: "Nexa Bold",
                          color: Colors.white,
                          fontSize: 16
                      ),
                    ),
                  ),
                ),
            ): const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text){
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                  fontFamily: "Nexa Bold",
                  color: Colors.black87
              ),
            ),
          ),
          Container(
            height: kToolbarHeight,
            width: screenWidth,
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.only(left: 11),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Colors.black54
                )
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                    fontFamily: "Nexa Bold",
                    color: Colors.black54,
                    fontSize: 16
                ),
              ),
            ),
          ),
        ],
      );
  }
  Widget textField(String title, String hint, TextEditingController controller){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Nexa Bold",
              color: Colors.black87
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                    color: Colors.black26,
                    fontFamily: 'Nexa Bold'
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black
                    )
                )
            ),
          ),
        ),
      ],
    );
  }


  void showSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
          content: Text(
        text,
      )
      ),
    );
  }
}


