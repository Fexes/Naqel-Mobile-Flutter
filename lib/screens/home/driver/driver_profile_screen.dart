import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:country_list_pick/support/code_country.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:naqelapp/models/driver/documents/DrivingLicence.dart';
import 'package:naqelapp/models/driver/documents/EntryExitCard.dart';
import 'package:naqelapp/models/driver/documents/IdentityCard.dart';
import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
 import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:progress_dialog/progress_dialog.dart';
 import '../../../utilts/URLs.dart';
import 'package:path/path.dart';

class DriverProfilePage extends StatefulWidget  {


  const DriverProfilePage({Key key}) : super(key: key);



  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage>  {

  bool checkEmails = true;
  bool checkTerms = true;
  bool showText = true;

  FocusNode _focusNodeEmail, _focusNodePass, _focusNodeConPass,_focusNodeMobile,_focusNodeFirstName,_focusNodeLastName,_focusNodeNationality,_focusNodeAddress;
  FocusNode _focusNodeLicencenumber,_focusNodLicenceype,_focusNodeIdentityCard;



  @override
  void initState() {
    super.initState();
    loadData();


    _focusNodeIdentityCard = new FocusNode();
    _focusNodeIdentityCard.addListener(_onOnFocusNodeEvent);


    _focusNodeLicencenumber = new FocusNode();
    _focusNodeLicencenumber.addListener(_onOnFocusNodeEvent);

    _focusNodLicenceype = new FocusNode();
    _focusNodLicenceype.addListener(_onOnFocusNodeEvent);


    _focusNodeEmail = new FocusNode();
    _focusNodeEmail.addListener(_onOnFocusNodeEvent);

    _focusNodePass = new FocusNode();
    _focusNodePass.addListener(_onOnFocusNodeEvent);

    _focusNodeConPass = new FocusNode();
    _focusNodeConPass.addListener(_onOnFocusNodeEvent);

    _focusNodeMobile = new FocusNode();
    _focusNodeMobile.addListener(_onOnFocusNodeEvent);

    _focusNodeFirstName = new FocusNode();
    _focusNodeFirstName.addListener(_onOnFocusNodeEvent);

    _focusNodeLastName = new FocusNode();
    _focusNodeLastName.addListener(_onOnFocusNodeEvent);

    _focusNodeNationality = new FocusNode();
    _focusNodeNationality.addListener(_onOnFocusNodeEvent);

    _focusNodeAddress = new FocusNode();
    _focusNodeAddress.addListener(_onOnFocusNodeEvent);
  }
  @override
  void dispose() {
    super.dispose();
    _focusNodeEmail.dispose();
  }
  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }
  String first_name,last_name,date_of_birth,gender,nationality,mobilenumber,address;
  int driver_id;
  String email;
  String password;
  String password2;
  var errorText;
  File _image,_imageLicence,_imageID;

  String LicenceNumber,LicenceType,identityCard;


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
    setState(() {
      _image = image;
      if(_image!=null) {
        pr.show();
        uploadPic();
      }
    });
  }
  BuildContext context;
  Future getLicenceImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
     setState(() {
       _imageLicence = image;
     });

    _displayLicencedDialog(context);
   }
  Future getIDImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
    setState(() {
      _imageID = image;
    });

    _displayIdDialog(context);
  }
  _displayLicencedDialog(BuildContext context) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: LicencedialogContent(context),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }

  _displayIdDialog(BuildContext context) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: IddialogContent(context),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }

  void showPassword() {
    setState(() {
      showText =! showText;
    });
  }

  DateTime selectedDate = DateTime.now();
  String dateSelDOB = "Select Date of Birth";

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1920, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {


        selectedDate = new DateTime(picked.year, picked.month, picked.day);
        String day = selectedDate.day.toString();
        String month ;
        String year = selectedDate.year.toString();

        switch (selectedDate.month) {
          case 1:
            month = "Jan";
            break;
          case 2:
            month = "Feb";
            break;
          case 3:
            month = "Mar";
            break;
          case 4:
            month = "Apr";
            break;
          case 5:
            month = "May";
            break;
          case 6:
            month = "Jun";
            break;
          case 7:
            month = "Jul";
            break;
          case 8:
            month = "Aug";
            break;
          case 9:
            month = "Sep";
            break;
          case 10:
            month = "Oct";
            break;
          case 11:
            month = "Nov";
            break;
          case 12:
            month = "Dec";
            break;
        }


        dateSelDOB=day+' - '+month+' - '+year;
        date_of_birth=dateSelDOB;
      });
  }

  String dateSelLicenceExp = "Select Expiry Date";
  Future<Null> _selectDateLicenceExp(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1920, 1),
        lastDate: DateTime(2070, 1));
    if (picked != null && picked != selectedDate)
      setState(() {



        selectedDate = new DateTime(picked.year, picked.month, picked.day);
        String day = selectedDate.day.toString();
        String month ;
        String year = selectedDate.year.toString();

        switch (selectedDate.month) {
          case 1:
            month = "Jan";
            break;
          case 2:
            month = "Feb";
            break;
          case 3:
            month = "Mar";
            break;
          case 4:
            month = "Apr";
            break;
          case 5:
            month = "May";
            break;
          case 6:
            month = "Jun";
            break;
          case 7:
            month = "Jul";
            break;
          case 8:
            month = "Aug";
            break;
          case 9:
            month = "Sep";
            break;
          case 10:
            month = "Oct";
            break;
          case 11:
            month = "Nov";
            break;
          case 12:
            month = "Dec";
            break;
        }


        dateSelLicenceExp=day+'-'+month+'-'+year;

        _displayLicencedDialog(context);


      });
  }

  String dateSelLicenceRel = "Select Release Date";
  Future<Null> _selectDateLicenceRel(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1920, 1),
        lastDate: DateTime(2070, 1));
    if (picked != null && picked != selectedDate)
      setState(() {



        selectedDate = new DateTime(picked.year, picked.month, picked.day);
        String day = selectedDate.day.toString();
        String month ;
        String year = selectedDate.year.toString();

        switch (selectedDate.month) {
          case 1:
            month = "Jan";
            break;
          case 2:
            month = "Feb";
            break;
          case 3:
            month = "Mar";
            break;
          case 4:
            month = "Apr";
            break;
          case 5:
            month = "May";
            break;
          case 6:
            month = "Jun";
            break;
          case 7:
            month = "Jul";
            break;
          case 8:
            month = "Aug";
            break;
          case 9:
            month = "Sep";
            break;
          case 10:
            month = "Oct";
            break;
          case 11:
            month = "Nov";
            break;
          case 12:
            month = "Dec";
            break;
        }


        dateSelLicenceRel=day+'-'+month+'-'+year;

        _displayLicencedDialog(context);


      });
  }



  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formLicenceKey = GlobalKey<FormState>();

  int selectedRadio;

// Changes the selected value on 'onChanged' click on each radio button
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
      switch (val){
        case 1:
          gender="Male";
          break;
        case 2:
          gender="Female";
          break;
        case 3:
          gender="Other";
          break;
      }
    });
  }


  int DriverID ;
  String Username ,PhotoURL;
  String Password ;
  String PhoneNumber ;
  String FirstName ;
  String LastName ;
  String Nationality;
  String Email ;
  String Gender  ;
  String DateOfBirth ;
  String Address ;
  int Active;
  Future<Timer> loadData()  {


    DriverID = DataStream.driverProfile.DriverID;
    Username = DataStream.driverProfile.Username;
    PhotoURL =  DataStream.driverProfile.PhotoURL;
    Password =  DataStream.driverProfile.Password;
    PhoneNumber =   DataStream.driverProfile.PhoneNumber;
    FirstName = DataStream.driverProfile.FirstName;
    LastName =  DataStream.driverProfile.LastName;
    Nationality =  DataStream.driverProfile.Nationality;
    Email =   DataStream.driverProfile.Email;
    Gender =  DataStream.driverProfile.Gender;
    DateOfBirth =  DataStream.driverProfile.DateOfBirth;
    Address =   DataStream.driverProfile.Address;
    Active =  DataStream.driverProfile.Active;


    dateSelDOB=DateOfBirth;
    driver_id=DriverID;
    first_name=FirstName;
    last_name=LastName;
    date_of_birth=DateOfBirth;
    gender=Gender;
    nationality=Nationality;
    mobilenumber=PhoneNumber;
    address=Address;
    email=Email;

    setState(() {
      switch(Gender){
        case "Male":
          selectedRadio=1;
          setSelectedRadio(1);
          break;
        case "Female":
          selectedRadio=2;
          setSelectedRadio(2);
          break;
        case "Other":
          selectedRadio=3;
          setSelectedRadio(3);
          break;
      }
    });

     isloadentryexit=false;
     isloadidcard=false;
     isloadlicence=false;
    loadentryexit();
    loadidcard();
    loadlicence();

  }

  bool isloadentryexit=false;
  bool isloadidcard=false;
  bool isloadlicence=false;

  Future<void> loadlicence() async {
    print("Loading DrivingLicence");
    final client = HttpClient();
    try{
    final request = await client.getUrl(Uri.parse(URLs.getDrivingLicenceURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
     // print(response.statusCode);
      Map<String, dynamic> driverMap = jsonDecode(contents) as Map<String, dynamic>;
      isloadlicence = true;

      if(driverMap["DrivingLicence"]!= null) {
        DataStream.drivingLicence =
        new DrivingLicence.fromJson(driverMap["DrivingLicence"]);

      }
      setState(() {

      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  Future<void> loadentryexit() async {
    print("Loading EntryExitCard");

    final client = HttpClient();
    try {
      final request = await client.getUrl(
          Uri.parse(URLs.getEntryExitCardURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT " + DataStream.token);
      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        // print(response.statusCode);
        isloadentryexit = true;

        Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
            jsonDecode(contents));
        if (driverMap["EntryExitCard"] != null) {
          DataStream.entryExitCard =
          new EntryExitCard.fromJson(driverMap["EntryExitCard"]);
        }
        setState(() {

        });
      });
    }catch(e){

      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }
  Future<void> loadidcard() async {
    print("Loading IdentityCard");

    final client = HttpClient();
    try{
    final request = await client.getUrl(Uri.parse(URLs.getIdentityCardURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      // print(response.statusCode);
      isloadidcard = true;

      Map<String, dynamic> driverMap = jsonDecode(contents) as Map<String, dynamic>;

      if(driverMap["IdentityCard"]!= null) {

        DataStream.identityCard=new IdentityCard.fromJson(driverMap["IdentityCard"]);


      }
      setState(() {

      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  @override
  Widget build(BuildContext context) {
    this.context=context;
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: true);
    pr.style(
        message: '     Updating Profile...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    Widget firstNameForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      width: screenWidth(context)*0.35,
      child: Row(
        children: <Widget>[
          Icon(Icons.account_circle,color: DataStream.driverProfile.FirstName==""? Colors.redAccent : Colors.black,),
          Container(
            width: (screenWidth(context)*0.3)-4,
            child: TextFormField(

              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              keyboardType: TextInputType.text,
              onSaved: (String value) {
                if(!value.isEmpty){
                  first_name = value;
                }

              },
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter First Name';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                hintText: DataStream.driverProfile.FirstName,
                labelText: "First Name",
              ),
              focusNode: _focusNodeLastName,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeLastName.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget lastNameForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      width: screenWidth(context)*0.35,
      child: Row(
        children: <Widget>[
          Icon(Icons.account_circle,color: DataStream.driverProfile.LastName==""? Colors.redAccent : Colors.black,),
          Container(
            width: (screenWidth(context)*0.3)-4,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,

              keyboardType: TextInputType.text,
              onSaved: (String value) {
                if(!value.isEmpty)
                  last_name = value;
              },
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter Last Name';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                hintText: DataStream.driverProfile.LastName,
                labelText: "Last Name",
              ),
              focusNode: _focusNodeFirstName,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeFirstName.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget emailForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.mail),
          Container(
            width: screenWidth(context)*0.7,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              keyboardType: TextInputType.emailAddress,
              onSaved: (String value) {
                if(!value.isEmpty)
                  email = value;
              },
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter Email Id';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                hintText: DataStream.driverProfile.Email,
                labelText: "Email Address",
              ),
              focusNode: _focusNodeEmail,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeEmail.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget passwordForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock),
          Container(
            width: screenWidth(context)*0.72,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              onSaved: (value) => password = value,
              validator: (String value) {
                if(value.length < 6)
                  return 'Password should be 6 or more digits';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                labelText: "New Password",
              ),
              focusNode: _focusNodePass,
              obscureText: showText,
            ),
          ),
          InkWell(
              onTap: showPassword,
              child: showText ?  Icon(Icons.visibility_off,color: Colors.grey[500],) :
              Icon(Icons.visibility,color: primaryDark,)
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodePass.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget confirmPassword = Container(
      margin: EdgeInsets.only(bottom: 18.0),

      child: Row(
        children: <Widget>[
          Icon(Icons.lock),
          Container(
            width: screenWidth(context)*0.72,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              onSaved: (value) => password2 = value,
              validator: (String value) {
                if(value.length < 6)
                  return 'Password should be 6 or more digits';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                labelText: confermpassword,
              ),
              focusNode: _focusNodeConPass,
              obscureText: showText,
            ),
          ),
          InkWell(
              onTap: showPassword,
              child: showText ?  Icon(Icons.visibility_off,color: Colors.grey[500],) :
              Icon(Icons.visibility,color: primaryDark,)
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeConPass.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget mobile  = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.phone_android),
          Container(
            width: screenWidth(context)*0.7,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                if(!value.isEmpty)
                  mobilenumber = value;
              },
              validator: (String value) {
                if(value.length != 11)
                  return 'Mobile Number should be 11 digits';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),

                hintText: DataStream.driverProfile.PhoneNumber,
                labelText: "Mobile Number",

              ),
              focusNode: _focusNodeMobile,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeMobile.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget addressForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.home,color: DataStream.driverProfile.Address==""? Colors.redAccent : Colors.black,),
          Container(
            width: screenWidth(context)*0.7,
            child: TextFormField(
              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              onSaved: (String value) {
                if(!value.isEmpty)
                  address = value;
              },
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter Address';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),

                hintText: DataStream.driverProfile.Address,
                labelText: "Address",
              ),
              focusNode: _focusNodeAddress,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: _focusNodeAddress.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
        ),
      ),
    );

    Widget nationalityForm =  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.local_airport,color: DataStream.driverProfile.Nationality==""? Colors.redAccent : Colors.black,),
        Row(
          children: <Widget>[
            SizedBox(width: 10,),
            Text("Nationality",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(width: 10,),
            CountryListPick(

              isShowFlag: true,
              isShowTitle: true,
              isShowCode: false,
              isDownIcon: true,
              initialSelection: '+966',
              showEnglishName: true,
              onChanged: (CountryCode code) {

                nationality=code.name;
                print(code.name);

              },
            ),
          ],
        ),
      ],
    );

    Widget genderForm = Container(

        margin: EdgeInsets.only(bottom: 18.0),
        child: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: selectedRadio,
              activeColor: Colors.redAccent,
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadio(val);
              },
            ),

            InkWell(
              child: Text("Male"),
              onTap: () {setSelectedRadio(1);},
            ),
            Radio(
              value: 2,
              groupValue: selectedRadio,
              activeColor: Colors.redAccent,
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadio(val);
              },
            ),
            InkWell(
              child: Text("Female"),
              onTap: () {setSelectedRadio(2);},
            ),

            Radio(
              value: 3,
              groupValue: selectedRadio,
              activeColor: Colors.redAccent,
              onChanged: (val) {
                print("Radio $val");
                setSelectedRadio(val);
              },
            ),
            InkWell(
              child: Text("Other"),
              onTap: () {setSelectedRadio(3);},
            ),
          ],
        )
    );

    Widget date = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.calendar_today),
          SizedBox(width: 10,),
          Text("Date of Birth",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(width: 10,),
          Container(
            child: FlatButton(

              child: Text(dateSelDOB,textAlign: TextAlign.start,),
              onPressed: () => _selectDate(context),
            ),
          ),
          GestureDetector(
              onTap: () => _selectDate(context),
              child: Icon(Icons.keyboard_arrow_down)),

        ],
      ),

    );
    ScrollController _scrollController = new ScrollController();

    return Align(


        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,

            title: Stack(
              children: <Widget>[

                Positioned(
                  right: 5,
                  child: GestureDetector(
                      onTap: (){
                        loadData();

                      },
                      child: Icon(Icons.sync,color: Colors.grey[700],size: 22,)),
                ),


                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget>[
                      Text('Profile',style: TextStyle(color: Colors.black),),

                    ]
                ),

              ],

            ),
          ),
          backgroundColor: Color(0xffF7F7F7),
          body: GestureDetector(

              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[

                    Form(
                      key: _formKey,
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        margin: EdgeInsets.only(top: 10.0),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Stack(
                                      alignment:new Alignment(1, 1),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                          child: Container(
                                            height: 280,
                                            width: 280,
                                            decoration: BoxDecoration(

                                              shape: BoxShape.circle,
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: AppTheme.grey.withOpacity(0.6),
                                                    offset: const Offset(2.0, 4.0),
                                                    blurRadius: 8),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              const BorderRadius.all(Radius.circular(360.0)),
                                              child: _image == null
                                                  ?   DataStream.driverProfile.PhotoURL==null ? Icon(Icons.account_circle,color: Colors.grey,size: 0,) :  Image.network(DataStream.driverProfile.PhotoURL,fit: BoxFit.cover)

                                                  : Image.file(_image,fit: BoxFit.cover),

                                            ),
                                          ),
                                        ),

                                        new Positioned(
                                          right:10.0,
                                          bottom: 10.0,
                                          child:  FloatingActionButton(
                                            onPressed: getImage,
                                            backgroundColor: Colors.red[800],
                                            tooltip: 'Pick Image',
                                            child: Icon(Icons.add_a_photo),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 18, left: 4),
                                  child: Text(
                                    DataStream.driverProfile.Username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.grey,
                                      fontSize: 28,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.flag,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Nationality",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.Nationality}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.account_circle,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("First Name",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.FirstName}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.phone_android,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Phone Number",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.PhoneNumber}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.accessibility_new,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Gender",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.Gender}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),



                                      ],
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.email,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Emain",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.Email}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.account_circle,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Last Name",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.LastName}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.date_range,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Date Of Birth",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.driverProfile.DateOfBirth}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.home,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Address",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Container(
                                                  width: 200,
                                                  child: Text(
                                                    '${DataStream.driverProfile.Address}',
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),


                                      ],
                                    ),
                                  ],
                                ),


                                const SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30,0,30,0),
                                  child: Divider(
                                    height: 1,
                                    color: AppTheme.grey.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),

                                Text(
                                  "Update Info",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.grey,
                                    fontSize: 26,
                                  ),),
                                const SizedBox(
                                  height: 30,
                                ),

                                Container(
                                  alignment: AlignmentDirectional.center,

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Listener(
                                        child: new InkWell(
                                            child: updteDetails==true? Column(
                                              children: <Widget>[
                                                Icon(Icons.contact_mail,color: Colors.red,size: 30,),
                                                const SizedBox(height: 10,),
                                                Text("Details",style: TextStyle(color: Colors.red),),
                                                Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),

                                              ],
                                            ):Column(
                                              children: <Widget>[
                                                Icon(Icons.contact_mail,color: Colors.black,),
                                                const SizedBox(height: 10,),
                                                Text("Details",style: TextStyle(color: Colors.black),),

                                              ],
                                            ),
                                            onTap: () {

                                              if(!updteDetails){
                                              _scrollController.animateTo(
                                                550,
                                                curve: Curves.easeOut,
                                                duration: const Duration(milliseconds: 500),
                                              );
                                              setState(() {
                                                updteenteryexit=false;
                                                updteidcard=false;
                                                updtelicence=false;

                                                updteDetails=true;
                                                updteEmail=false;
                                                updtePAssword=false;
                                              });
                                              }else{
                                                setState(() {
                                                  updtePAssword = false;
                                                  updteDetails = false;
                                                  updteEmail = false;
                                                });
                                              }
                                            }
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),

                                      new Listener(
                                        child: new InkWell(
                                            child: updteEmail==true? Column(
                                              children: <Widget>[
                                                Icon(Icons.mail,color: Colors.red,size: 30,),
                                                const SizedBox(height: 10,),
                                                Text("Email",style: TextStyle(color: Colors.red),),
                                                Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),
                                              ],
                                            ):Column(
                                              children: <Widget>[
                                                Icon(Icons.mail,color: Colors.black,),
                                                const SizedBox(height: 10,),
                                                Text("Email",style: TextStyle(color: Colors.black),),

                                              ],
                                            )
                                            ,
                                            onTap: () {

                                              if(!updteEmail){
                                              _scrollController.animateTo(
                                                200,
                                                curve: Curves.easeOut,
                                                duration: const Duration(milliseconds: 500),
                                              );
                                              setState(() {
                                                updteenteryexit=false;
                                                updteidcard=false;
                                                updtelicence=false;

                                                updteEmail=true;
                                                updteDetails=false;
                                                updtePAssword=false;

                                              });
                                              }else{
                                                setState(() {
                                                  updtePAssword = false;
                                                  updteDetails = false;
                                                  updteEmail = false;
                                                });
                                              }
                                            }
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      new Listener(
                                        child: new InkWell(
                                            child: updtePAssword==true? Column(
                                              children: <Widget>[
                                                Icon(Icons.lock,color: Colors.red,size: 30,),
                                                const SizedBox(height: 10,),
                                                Text("Password",style: TextStyle(color: Colors.red),),
                                                Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),

                                              ],
                                            ):Column(
                                              children: <Widget>[
                                                Icon(Icons.lock,color: Colors.black,),
                                                const SizedBox(height: 10,),
                                                Text("Password",style: TextStyle(color: Colors.black),),

                                              ],
                                            ),
                                            onTap: () {

                                              if(!updtePAssword) {
                                                _scrollController.animateTo(
                                                  250,
                                                  curve: Curves.easeOut,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                );
                                                setState(() {
                                                  updteenteryexit=false;
                                                  updteidcard=false;
                                                  updtelicence=false;

                                                  updtePAssword = true;
                                                  updteDetails = false;
                                                  updteEmail = false;
                                                });
                                              }else{
                                                setState(() {
                                                  updtePAssword = false;
                                                  updteDetails = false;
                                                  updteEmail = false;
                                                });
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),



                              ],
                            ),
                            Visibility(
                              visible: updteDetails,
                              child: Container(

                                alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0, right: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Text("General Details",),
                                    SizedBox(height: 10,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        firstNameForm,
                                        SizedBox(width: (screenWidth(context)*0.1)+16),
                                        lastNameForm
                                      ],
                                    ),


                                    mobile,
                                    addressForm,
                                    nationalityForm,
                                    date,
                                    genderForm,


                                    Container(
                                      alignment: AlignmentDirectional.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
                                        child: SizedBox(
                                          width: 200,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(18.0),

                                            ),

                                            color: primaryDark,
                                            onPressed: ()  {
                                              final FormState form = _formKey.currentState;
                                              form.save();

                                              updateSettings(context);

                                            },
                                            child: Text( "UPDATE",style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: updteEmail,
                              child: Container(

                                alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0, right: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Text("Email", ),
                                    SizedBox(height: 10,),
                                    emailForm,

                                    Container(
                                      alignment: AlignmentDirectional.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
                                        child: SizedBox(
                                          width: 200,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(18.0),

                                            ),

                                            color: primaryDark,
                                            onPressed: ()  {
                                              final FormState form = _formKey.currentState;
                                              form.save();

                                              updateEmailSettings(context);

                                            },
                                            child: Text( "UPDATE",style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: updtePAssword,
                              child: Container(

                                alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0, right: 16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Text("Passwords",),
                                    SizedBox(height: 10,),
                                    passwordForm,
                                    confirmPassword,

                                    Container(
                                      alignment: AlignmentDirectional.center,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
                                        child: SizedBox(
                                          width: 200,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(18.0),

                                            ),

                                            color: primaryDark,
                                            onPressed: ()  {
                                              final FormState form = _formKey.currentState;
                                              form.save();

                                              updatePassword(context);

                                            },
                                            child: Text( "UPDATE",style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30,0,30,0),
                              child: Divider(
                                height: 1,
                                color: AppTheme.grey.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),

                            Text(
                              "Documents",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 26,
                              ),),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              alignment: AlignmentDirectional.center,

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Listener(
                                    child: new InkWell(
                                        child: updteidcard==true? Column(
                                          children: <Widget>[
                                            Icon(Icons.account_box,color: Colors.red,size: 30,),
                                            const SizedBox(height: 10,),
                                            Text("Id Card",style: TextStyle(color: Colors.red),),
                                            Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),

                                          ],
                                        ):Column(
                                          children: <Widget>[
                                            Icon(Icons.account_box,color: Colors.black,),
                                            const SizedBox(height: 10,),
                                            Text("Id Card",style: TextStyle(color: Colors.black),),

                                          ],
                                        ),
                                        onTap: () {



                                          if(!updteidcard) {
                                            _scrollController.animateTo(
                                              440,
                                              curve: Curves.easeOut,
                                              duration: const Duration(milliseconds: 500),
                                            );

                                             updteDetails=false;
                                             updteEmail=false;
                                             updtePAssword=false;

                                            setState(() {
                                              updteidcard = true;
                                              updtelicence = false;
                                              updteenteryexit = false;


                                            });
                                          }else{
                                            setState(() {
                                              updteenteryexit=false;
                                              updteidcard=false;
                                              updtelicence=false;
                                            });
                                          }
                                        }
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),

                                  new Listener(
                                    child: new InkWell(
                                        child: updtelicence==true? Column(
                                          children: <Widget>[
                                            Icon(Icons.airport_shuttle,color: Colors.red,size: 30,),
                                            const SizedBox(height: 10,),
                                            Text("Licence",style: TextStyle(color: Colors.red),),
                                            Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),
                                          ],
                                        ):Column(
                                          children: <Widget>[
                                            Icon(Icons.airport_shuttle,color: Colors.black,),
                                            const SizedBox(height: 10,),
                                            Text("Licence",style: TextStyle(color: Colors.black),),

                                          ],
                                        )
                                        ,
                                        onTap: () {
                                          if (!updtelicence) {
                                            _scrollController.animateTo(
                                              490,
                                              curve: Curves.easeOut,
                                              duration: const Duration(milliseconds: 500),
                                            );

                                            updteDetails=false;
                                            updteEmail=false;
                                            updtePAssword=false;

                                            setState(() {
                                              updtelicence = true;
                                              updteidcard = false;
                                              updteenteryexit = false;
                                            });
                                          } else {
                                            setState(() {
                                              updteenteryexit=false;
                                              updteidcard=false;
                                              updtelicence=false;
                                            });
                                          }
                                        }
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  new Listener(
                                    child: new InkWell(
                                        child: updteenteryexit==true? Column(
                                          children: <Widget>[
                                            Icon(Icons.exit_to_app,color: Colors.red,size: 30,),
                                            const SizedBox(height: 10,),
                                            Text("Entry / Exit",style: TextStyle(color: Colors.red),),
                                            Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),

                                          ],
                                        ):Column(
                                          children: <Widget>[
                                            Icon(Icons.exit_to_app,color: Colors.black,),
                                            const SizedBox(height: 10,),
                                            Text("Entry / Exit",style: TextStyle(color: Colors.black),),

                                          ],
                                        ),
                                        onTap: () {

                                          if(!updteenteryexit){
                                            _scrollController.animateTo(
                                              340,
                                              curve: Curves.easeOut,
                                              duration: const Duration(milliseconds: 500),
                                            );

                                            updteDetails=false;
                                            updteEmail=false;
                                            updtePAssword=false;

                                          setState(() {

                                            updteenteryexit=true;
                                            updteidcard=false;
                                            updtelicence=false;

                                          });
                                            }else{
                                            setState(() {
                                              updteenteryexit=false;
                                              updteidcard=false;
                                              updtelicence=false;

                                            });
                                            }
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: updtelicence,
                              child:isloadlicence?
                              DataStream.drivingLicence!=null?Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InkWell(
                                        // When the user taps the button, show a snackbar.
                                        onTap: () {

                                          deleteLicence();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.cancel,
                                            color: Colors.redAccent, size: 30,),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                        child: Container(
                                          height: 200,
                                          width: 300,
                                          decoration: BoxDecoration(

                                            shape: BoxShape.rectangle,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: AppTheme.grey.withOpacity(0.6),
                                                  offset: const Offset(2.0, 4.0),
                                                  blurRadius: 8),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            const BorderRadius.all(Radius.circular(10.0)),
                                            child: Image.network(DataStream.drivingLicence.PhotoURL,fit: BoxFit.cover),

                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                      children: <Widget>[

                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text("Licence Number: ",
                                                style: TextStyle(
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text("Licence Type: ",
                                                style: TextStyle(
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text("Release Date: ",
                                                style: TextStyle(
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text("Expiry Date: ",
                                                style: TextStyle(
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text(
                                                DataStream.drivingLicence.LicenceNumber,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text(
                                                DataStream.drivingLicence.Type,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text(
                                                DataStream.drivingLicence.ReleaseDate,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text(
                                                DataStream.drivingLicence.ExpiryDate,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "No Driving Licence Added",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  FloatingActionButton(
                                    onPressed:(){

                                     _displayLicencedDialog(context);

                                    },
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Loading Driving Licence",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),

                            ),
                            Visibility(
                              visible: updteidcard,
                              child:isloadidcard?
                              DataStream.identityCard!=null?Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InkWell(
                                        // When the user taps the button, show a snackbar.
                                        onTap: () {

                                          deleteIdCard();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.cancel,
                                            color: Colors.redAccent, size: 30,),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                        child: Container(
                                          height: 200,
                                          width: 300,
                                          decoration: BoxDecoration(

                                            shape: BoxShape.rectangle,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: AppTheme.grey.withOpacity(0.6),
                                                  offset: const Offset(2.0, 4.0),
                                                  blurRadius: 8),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            const BorderRadius.all(Radius.circular(10.0)),
                                            child: Image.network(DataStream.identityCard.PhotoURL,fit: BoxFit.cover),

                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                       Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text("ID card Number: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),


                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text(
                                              DataStream.identityCard.IDNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),


                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "No Identity Card Added",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      _displayIdDialog(context);
                                    },
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Loading Identity Card",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),

                                ],
                              ),

                            ),
                            Visibility(
                              visible: updteenteryexit,
                              child:isloadidcard?
                              DataStream.entryExitCard!=null?Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                        // When the user taps the button, show a snackbar.
                                        onTap: () {

                                          deleteEnteryExit();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(Icons.cancel,
                                            color: Colors.redAccent, size: 30,),
                                        ),
                                      ),

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text("Entry / Exit Number: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text("Type: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text("Release Date: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text("Number Of Months: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),


                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text(
                                              DataStream.entryExitCard.EntryExitNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text(
                                              DataStream.entryExitCard.Type,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text(
                                              DataStream.entryExitCard.ReleaseDate,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 0, left: 0),
                                            child: Text(
                                              DataStream.entryExitCard.NumberOfMonths.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "No Entery / Exit card Added",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),

                                ],
                              ):
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Loading Entery / Exit Card",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),

                                ],
                              ),

                            ),
                            const SizedBox(
                              height: 30,
                            ),



                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),

        ),

    );
  }
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }

    return double.parse(s, (e) => null) != null ||
        int.parse(s, onError: (e) => null) != null;
  }

  bool updteDetails=false;
  bool updteEmail=false;
  bool updtePAssword=false;

  bool updteenteryexit=false;
  bool updteidcard=false;
  bool updtelicence=false;

  ProgressDialog pr;
  Future updateSettings(BuildContext context) async {


    if(isNumeric(mobilenumber)) {
      pr.show();

      final client = HttpClient();
      try{
      final request = await client.postUrl(Uri.parse(URLs.generalSettingUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      request.write('{"FirstName": "' + first_name +'","LastName": "' + last_name +
          '", "Address": "' + address + '", "DateOfBirth": "' + date_of_birth +
          '", "PhoneNumber": "' + mobilenumber + '", "Gender": "' + gender +
          '", "Nationality": "' + nationality + '"}');

      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);
        ToastUtils.showCustomToast(
            context, "Details Updated Successfully", true);

        pr.hide();

        Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;

        _image = null;
        setState(() {
          DataStream.driverProfile.FirstName=first_name;
          DataStream.driverProfile.LastName=last_name;
          DataStream.driverProfile.Address=address;
          DataStream.driverProfile.DateOfBirth=date_of_birth;
          DataStream.driverProfile.PhoneNumber=mobilenumber;
          DataStream.driverProfile.Gender=gender;
          DataStream.driverProfile.Nationality=nationality;
        });
      });
    }catch(e){

    print(e);
    ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
    //pr.hide();

    }
    }else{
      ToastUtils.showCustomToast(context, "Invalid Phone Number",false);

    }
  }

  Future updateEmailSettings(BuildContext context) async {

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }
    if(EmailValidator.validate(email)) {
      pr.show();

      final client = HttpClient();
      try{
      final request = await client.postUrl(Uri.parse(URLs.emailSettingUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

     request.write('{"Username": "' + DataStream.driverProfile.Username +
          '", "Email": "' + email + '"}');

      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);
        ToastUtils.showCustomToast(context, "Email Updated Successfully", true);

        pr.hide();

        _image = null;
        setState(() {
          DataStream.driverProfile.Email=email;
        });
      });
    }catch(e){

    print(e);
    ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
    //pr.hide();

    }
    }else{
      ToastUtils.showCustomToast(context, "Invalid Email Address", false);

    }
  }

  Future updatePassword(BuildContext context) async {

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }
    if(password==password2&&(password!=""||password2!="")) {
      confermpassword="Confirm Password";
      pr.show();
      final client = HttpClient();
      try{
      final request = await client.postUrl(Uri.parse(URLs.passwordSettingUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


         request.write('{"Password": "' + password + '"}');
      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);
        pr.hide();
        ToastUtils.showCustomToast(context, "Password Updated Successfully",true);

        _image = null;
        setState(() {
          // Re-renders
        });
      });
    }catch(e){

    print(e);
    ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
    //pr.hide();

    }
    }else if (password==""||password2==""){
      pr.hide();
      ToastUtils.showCustomToast(context, "Please Enter Password",false);
      setState(() {
        // Re-renders
      });
    }
    else{
      pr.hide();
      ToastUtils.showCustomToast(context, "Password Does Not Match",false);
      setState(() {
        // Re-renders
      });
    }
  }


  String confermpassword="Confirm Password";
  Future updatePicUrl(String s) async {

    print("Updating URL");

    final client = HttpClient();
    try{
    final request = await client.postUrl(Uri.parse(URLs.updatePhotoUrlInDatabase()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    request.write('{"URL": "'+s+'", "FileName": "'+DataStream.driverProfile.Username+'"}');

    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);



      pr.hide();

      DefaultCacheManager manager = new DefaultCacheManager();
      manager.emptyCache();

      Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;

      _image=null;
      setState(() {
        DataStream.driverProfile.PhotoURL=s;
      });


    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }

  }

  Future uploadPic() async{

    print("Uploading picture");
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("ProfilePhoto").child("$driver_id");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL();

    String s =await (await uploadTask.onComplete).ref.getDownloadURL();
    print (s);
    updatePicUrl(s);


  }

  Future uploadLicencePic() async{

    print("Uploading picture");
    String fileName = basename(_imageLicence.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("Licence").child("$driver_id");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageLicence);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL();

    String s =await (await uploadTask.onComplete).ref.getDownloadURL();
    print (s);
    addLicence(s);


  }

  Future uploadIDPic() async{

    print("Uploading picture");
    String fileName = basename(_imageID.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("IdentityCard").child("$driver_id");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageID);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL();

    String s =await (await uploadTask.onComplete).ref.getDownloadURL();
    print (s);
    addIdcard(s);



  }

  Future<void> addLicence(String s) async {

    final client = HttpClient();
    try{
    final request = await client.postUrl(Uri.parse(URLs.addDrivingLicenceURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    request.write('{"LicenceNumber": "'+LicenceNumber+'", "Type": "'+LicenceType+'", "ReleaseDate": "'+dateSelLicenceExp+'", "ExpiryDate": "'+dateSelLicenceRel+'", "PhotoURL": "'+s+'"}');

    final response = await request.close();


    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      pr.hide();
       setState(() {
         _imageLicence=null;
        LicenceNumber="";
        LicenceType="";
        dateSelLicenceExp="Select Expiry Date";
        dateSelLicenceRel="Select Release Date";
        loadData();
      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  Future<void> deleteEnteryExit() async {
    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deleteEntryExitCardURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      DataStream.entryExitCard=null;
      setState(() {
        loadData();
      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  Future<void> deleteIdCard() async {
    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deleteIdentityCardURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      DataStream.identityCard=null;
      setState(() {
        loadData();
      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  Future<void> deleteLicence() async {
    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deleteDrivingLicenceURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      DataStream.drivingLicence=null;

      setState(() {
        loadData();
      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  Future<void> addIdcard(String s) async {
    final client = HttpClient();
    try{
    final request = await client.postUrl(Uri.parse(URLs.addIdentityCardURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    request.write('{"IDNumber": "'+identityCard+'",  "PhotoURL": "'+s+'"}');

    final response = await request.close();


    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      pr.hide();
      setState(() {
        _imageID=null;
        identityCard="";

        loadData();
      });
    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  LicencedialogContent(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formLicenceKey,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 90.0+ 16.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              margin: EdgeInsets.only(top: 90.0),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),

                child: Column(

                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    SizedBox(height: 16.0),

                    Text(
                      "Add New Licence",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.confirmation_number),
                          Container(
                            width: screenWidth(context)*0.5,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.number,
                              initialValue: LicenceNumber,
                              onSaved: (String value) {
                                if(!value.isEmpty)
                                  LicenceNumber = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Licence Number';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Licence Number",

                              ),
                              focusNode: _focusNodeLicencenumber,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: _focusNodeLicencenumber.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                        ),
                      ),
                    ),
                    //  SizedBox(height: 16.0),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.code),
                          Container(
                            width: screenWidth(context)*0.5,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.number,
                               initialValue: LicenceType,
                               onSaved: (String value) {
                                if(!value.isEmpty)
                                  LicenceType = value;

                                print(LicenceType);
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Licence Code';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Licence Code",


                              ),
                              focusNode: _focusNodLicenceype,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: _focusNodLicenceype.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                        ),
                      ),
                    ),
                    // SizedBox(height: 16.0),

                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.calendar_today),
                          Container(
                            child: FlatButton(

                              child: Text(dateSelLicenceExp,textAlign: TextAlign.start,),
                              onPressed: () {
                                Navigator.of(context).pop();
                                final FormState form = _formLicenceKey.currentState;
                                form.save();
                                _selectDateLicenceExp(context);
                                // To close the dialog

                              },
                            ),
                          ),
                        ],
                      ),

                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.calendar_today),
                          Container(
                            child: FlatButton(

                              child: Text(dateSelLicenceRel,textAlign: TextAlign.start,),
                              onPressed: () {
                                Navigator.of(context).pop();
                                final FormState form = _formLicenceKey.currentState;
                                form.save();
                                _selectDateLicenceRel(context);
                                // To close the dialog

                              },
                            ),
                          ),
                        ],
                      ),

                    ),
                    // SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _imageLicence=null;
                              LicenceNumber="";
                              LicenceType="";
                              dateSelLicenceExp="Select Expiry Date";
                              dateSelLicenceRel="Select Release Date";
                              _imageLicence=null;
                              Navigator.of(context).pop(); // To close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              pr.show();

                              final FormState form = _formLicenceKey.currentState;
                              form.save();

                              uploadLicencePic();
                            },
                            child: Text("Add"),
                          ),
                        ),
                      ],

                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 76.0,
              right: 76.0,
              child:  GestureDetector(
                onTap: (){
                  final FormState form = _formLicenceKey.currentState;
                  form.save();
                   getLicenceImage();
                  Navigator.of(context).pop();
                },
                child: new Stack(
                  alignment:new Alignment(1, 1),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(

                          shape: BoxShape.rectangle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.grey,
                                offset: const Offset(2.0, 4.0),
                                blurRadius: 12),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(15)),
                          child: _imageLicence == null
                              ?    Icon(Icons.add,color: Colors.white,size: 130,)

                              : Image.file(_imageLicence,fit: BoxFit.cover),

                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );


  }

  IddialogContent(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formLicenceKey,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 90.0+ 16.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              margin: EdgeInsets.only(top: 90.0),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),

                child: Column(

                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    SizedBox(height: 20.0),

                    Text(
                      "Add New Identity Card",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.confirmation_number),
                          Container(
                            width: screenWidth(context)*0.5,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.number,
                              initialValue: identityCard,
                              onSaved: (String value) {
                                if(!value.isEmpty)
                                  identityCard = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Identity Card Number';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Identity Card Number",

                              ),
                              focusNode: _focusNodeIdentityCard,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: _focusNodeIdentityCard.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                        ),
                      ),
                    ),
                    //  SizedBox(height: 16.0),

                    // SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _imageID=null;
                              identityCard="";
                              _imageLicence=null;
                              Navigator.of(context).pop(); // To close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              pr.show();

                              final FormState form = _formLicenceKey.currentState;
                              form.save();

                              uploadIDPic();
                            },
                            child: Text("Add"),
                          ),
                        ),
                      ],

                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 76.0,
              right: 76.0,
              child:  GestureDetector(
                onTap: (){
                  final FormState form = _formLicenceKey.currentState;
                  form.save();
                  getIDImage();
                  Navigator.of(context).pop();
                },
                child: new Stack(
                  alignment:new Alignment(1, 1),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(

                          shape: BoxShape.rectangle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.grey,
                                offset: const Offset(2.0, 4.0),
                                blurRadius: 12),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(15)),
                          child: _imageID == null
                              ?    Icon(Icons.add,color: Colors.white,size: 130,)

                              : Image.file(_imageID,fit: BoxFit.cover),

                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );


  }



}
