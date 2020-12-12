import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:naqelapp/models/driver/documents/DrivingLicence.dart';
import 'package:naqelapp/models/driver/documents/EntryExitCard.dart';
import 'package:naqelapp/models/driver/documents/IdentityCard.dart';
import 'package:naqelapp/models/trader/documents/CommercialRegisterCertificate.dart';
import 'package:naqelapp/models/trader/documents/TraderIdentityCard.dart';
import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../../utilts/URLs.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CompanyProfilePage extends StatefulWidget  {


  const CompanyProfilePage({Key key}) : super(key: key);



  @override
  _CompanyProfilePageState createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage>  {

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
  int trader_id;
  String email;
  String password;
  String password2;
  var errorText;
  File _imageLicence,_imageID;

  String LicenceNumber,LicenceType,identityCard;



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



  int selectedRadio;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formLicenceKey = GlobalKey<FormState>();



  int TransportCompanyResponsibleID ;
  String Username ;
  String Password ;
  String PhoneNumber ;
  String Name ;
  String Email ;
  int Active;
  Future<Timer> loadData()  {


    TransportCompanyResponsibleID = DataStream.transportCompanyResponsibleProfle.TransportCompanyResponsibleID;
    Username = DataStream.transportCompanyResponsibleProfle.Username;
     Password =  DataStream.transportCompanyResponsibleProfle.Password;
    PhoneNumber =   DataStream.transportCompanyResponsibleProfle.PhoneNumber;
    Name = DataStream.transportCompanyResponsibleProfle.Name;
    Email =   DataStream.transportCompanyResponsibleProfle.Email;
    Active =  DataStream.transportCompanyResponsibleProfle.Active;


    trader_id=TransportCompanyResponsibleID;
    first_name=Name;
    mobilenumber=PhoneNumber;
    email=Email;



      isloadidcard=false;
     isloadlicence=false;

    loadlicence();

  }

   bool isloadidcard=false;
  bool isloadlicence=false;

  Future<void> loadlicence() async {
    print("Loading CommercialRegisterCertificate");
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(URLs.getCommercialRegisterCertificateUrl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
     // print(response.statusCode);
      Map<String, dynamic> driverMap = jsonDecode(contents) as Map<String, dynamic>;
      isloadlicence = true;

      if(driverMap["CommercialRegisterCertificate"]!= null) {
        DataStream.commercialRegisterCertificate =
        new CommercialRegisterCertificate.fromJson(driverMap["CommercialRegisterCertificate"]);

      }
      setState(() {

      });
    });
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
          Icon(Icons.account_circle,color: DataStream.transportCompanyResponsibleProfle.Name==""? Colors.redAccent : Colors.black,),
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
                hintText: DataStream.transportCompanyResponsibleProfle.Name,
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
                hintText: DataStream.transportCompanyResponsibleProfle.Email,
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

                hintText: DataStream.transportCompanyResponsibleProfle.PhoneNumber,
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


                                Padding(
                                  padding: const EdgeInsets.only(top: 18, left: 4),
                                  child: Text(
                                    DataStream.transportCompanyResponsibleProfle.Username,
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
                                            Icon(Icons.account_circle,
                                              color: Colors.teal, size: 25,),
                                            SizedBox(width: 5),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[

                                                Text("Name",
                                                  style: TextStyle(
                                                    color: AppTheme.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  '${DataStream.transportCompanyResponsibleProfle.Name}',
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
                                                  '${DataStream.transportCompanyResponsibleProfle.PhoneNumber}',
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
                                                  '${DataStream.transportCompanyResponsibleProfle.Email}',
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
                                                150,
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
                                                100,
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
                                                  150,
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

                                      ],
                                    ),

                                    mobile,


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
                                            Icon(Icons.contact_mail,color: Colors.red,size: 30,),
                                            const SizedBox(height: 10,),
                                            Text("Certificate",style: TextStyle(color: Colors.red),),
                                            Text("                                                          ",style: TextStyle(fontSize: 8, color: Colors.red,decoration: TextDecoration.underline,decorationThickness: 5),),
                                          ],
                                        ):Column(
                                          children: <Widget>[
                                            Icon(Icons.contact_mail,color: Colors.black,),
                                            const SizedBox(height: 10,),
                                            Text("Certificate",style: TextStyle(color: Colors.black),),

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

                                ],
                              ),
                            ),
                            Visibility(
                              visible: updtelicence,
                              child:isloadlicence?
                              DataStream.commercialRegisterCertificate!=null?Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      InkWell(
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
                                            child: Image.network(DataStream.commercialRegisterCertificate.PhotoURL,fit: BoxFit.cover),

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
                                              child: Text("Number: ",
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


                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0, left: 0),
                                              child: Text(
                                                DataStream.commercialRegisterCertificate.Number,
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
                                                DataStream.commercialRegisterCertificate.Type,
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
                                    "No Register Certificate Added",
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
                                    "Loading Register Certificate",
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
                              DataStream.traderIdentityCard!=null?Column(
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
                                            child: Image.network(DataStream.traderIdentityCard.PhotoURL,fit: BoxFit.cover),

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
                                              DataStream.traderIdentityCard.IDNumber,
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
      final request = await client.postUrl(Uri.parse(URLs.tradergeneralSettingsUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      request.write('{"Name": "' + first_name +'","LastName": "' + last_name +
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


        setState(() {
          DataStream.transportCompanyResponsibleProfle.Name=first_name;
          DataStream.transportCompanyResponsibleProfle.PhoneNumber=mobilenumber;
        });
      });

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
      final request = await client.postUrl(Uri.parse(URLs.traderusernameAndEmailSettingsUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

     request.write('{"Username": "' + DataStream.transportCompanyResponsibleProfle.Username +
          '", "Email": "' + email + '"}');

      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);
        ToastUtils.showCustomToast(context, "Email Updated Successfully", true);

        pr.hide();

        setState(() {
          DataStream.transportCompanyResponsibleProfle.Email=email;
        });
      });
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
      final request = await client.postUrl(
          Uri.parse(URLs.traderpasswordSettingsSettingsUrl()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


         request.write('{ "Password": "' + password + '"}');
      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);
        pr.hide();
        ToastUtils.showCustomToast(context, "Password Updated Successfully",true);

        setState(() {
          // Re-renders
        });
      });
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




  Future uploadLicencePic() async{

    print("Uploading picture");
    String fileName = basename(_imageLicence.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("CommercialRegisterCertificateUrl").child("$trader_id");
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
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("IdentityCard").child("$trader_id");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageID);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL();

    String s =await (await uploadTask.onComplete).ref.getDownloadURL();
    print (s);
    addIdcard(s);



  }

  Future<void> addLicence(String s) async {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(URLs.addCommercialRegisterCertificateUrl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    request.write('{"Number": "'+LicenceNumber+'", "Type": "'+LicenceType+'",  "PhotoURL": "'+s+'"}');

    final response = await request.close();


    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      pr.hide();
       setState(() {
         _imageLicence=null;
        LicenceNumber="";
        LicenceType="";
        loadData();
      });
    });
  }



  Future<void> deleteIdCard() async {
    final client = HttpClient();
    final request = await client.deleteUrl(Uri.parse(URLs.traderdeleteIdentityCardUrl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);
    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);
      DataStream.traderIdentityCard=null;
      setState(() {
        loadData();
      });
    });
  }

  Future<void> deleteLicence() async {
    final client = HttpClient();
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
  }
  Future<void> addIdcard(String s) async {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(URLs.traderaddIdentityCardUrl()));
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
                                  return 'Enter Certificate Number';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Certificate Number",

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
                                  return 'Enter Certificate Code';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Certificate Code",


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
