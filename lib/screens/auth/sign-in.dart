import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:naqelapp/models/TransportCompany/CompanyProfle.dart';
import 'package:naqelapp/models/trader/TraderProfile.dart';
import 'package:naqelapp/screens/home/TransportCompany/company_navigation_home_screen.dart';
import 'package:naqelapp/screens/home/driver/driver_navigation_home_screen.dart';
import 'package:naqelapp/screens/home/trader/trader_navigation_home_screen.dart';
import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:flutter/material.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:naqelapp/screens/auth/sign-up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert' show jsonDecode, utf8;
import '../../utilts/URLs.dart';
import '../../utilts/DataStream.dart';
import '../../models/driver/DriverProfile.dart';
import 'forgot-password.dart';
import 'package:progress_dialog/progress_dialog.dart';



import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool isloadingDialogueShowing=false;

  bool isLoadingError=false;
  hideLoadingDialogue(){

    if(isloadingDialogueShowing) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      isloadingDialogueShowing=false;
      isLoadingError=false;
    }
  }
  showLoadingDialogue(String message){

    if(!isloadingDialogueShowing) {
      loadingdialog= Dialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child:   Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SpinKitFadingCircle(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index==1 ? Colors.orange[900] :index==2 ?Colors.orange[800] : index==3 ?Colors.orange[700] : index==4 ?
                      Colors.orange[600] :index==5 ?Colors.orange[500] : index==6 ?Colors.orange[400]:
                      index==1 ?Colors.orange[300] : index==1 ?Colors.orange[200] : index==1 ?Colors.orange[100] : index==1 ?
                      Colors.orange[100] :index==1 ?Colors.orange[100] :Colors.orange[900]
                      ,
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  );
                },
              ),
              Text(""+message, style: TextStyle(fontSize: 12,color: Colors.white),),
            ],
          )
      );
      showDialog(
          context: context, builder: (BuildContext context) => loadingdialog);
      showDialog(
          context: context, builder: (BuildContext context) => loadingdialog);
      isloadingDialogueShowing = true;
    }
    isLoadingError=true;


  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool checkRemember = true;
  bool showText = true;

  FocusNode _focusNode, _focusNode2;

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }
  Dialog loadingdialog;
  @override
  Future<void> initState()  {
    super.initState();




    _focusNode = new FocusNode();
    _focusNode.addListener(_onOnFocusNodeEvent);
    _focusNode2 = new FocusNode();
    _focusNode2.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  Color _getBorderColor() {
    return _focusNode.hasFocus ? primaryDark : border;
  }

  Color _getBorderColor2() {
    return _focusNode2.hasFocus ? primaryDark : border;
  }

  void showPassword() {
    setState(() {
      showText =! showText;
    });
  }

  String email;
  String password;
  var errorText;
  String loginas = 'Driver';

  List <String> spinnerItems = [
    'Driver',
    'Trader',
    'Broker',
    'Company',
  ] ;
  bool loading = false;





  void signin() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();




    final FormState form = _formKey.currentState;
       if (!form.validate()) {
      return;
    }


       showLoadingDialogue("Signing in");

    form.save();
    print(email);



    final client = HttpClient();

    try {

      var request;


      if(loginas=="Driver") {
        request = await client.postUrl(Uri.parse(URLs.loginUrl()));
        request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

        request.write(
            '{"PhoneNumberOrUsername": "' + email + '", "Password": "' + password +
                '", "LoginInAs": "Driver"}');

        await prefs.setString('LoginType', 'Driver');

      }else if (loginas=="Trader") {
        request = await client.postUrl(Uri.parse(URLs.traderLoginUrl()));
        request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

        request.write(
            '{"PhoneNumberOrUsername": "' + email + '", "Password": "' + password +
                '", "LoginInAs": "Trader"}');

        await prefs.setString('LoginType', 'Trader');

      }
      else if (loginas=="Broker") {
        request = await client.postUrl(Uri.parse(URLs.traderLoginUrl()));
        request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

        request.write(
            '{"PhoneNumberOrUsername": "' + email + '", "Password": "' + password +
                '", "LoginInAs": "Broker"}');

        await prefs.setString('LoginType', 'Broker');

      }
      else if (loginas=="Company") {

        request = await client.postUrl(Uri.parse(URLs.transportCompanyResponsiblesLoginURL()));
        request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

        request.write(
            '{"PhoneNumberOrUsername": "' + email + '", "Password": "' + password +
                '", "LoginInAs": "TC Responsible"}');

        await prefs.setString('LoginType', 'TC Responsible');


      }


      final response = await request.close();
      response.transform(utf8.decoder).listen((contents) async {
        print(contents);

        //  parseJwt(contents);

        hideLoadingDialogue();

        //Missing credentials
        if (contents.contains("Missing credentials")) {
          print("Missing credentials");

          ToastUtils.showCustomToast(context, "Missing credentials", false);
        }
        if (contents.contains("Invalid password")) {
          print("Invalid password");
           ToastUtils.showCustomToast(context, "Invalid password", false);
        }
        if (contents.contains("Driver not found")) {
          print("Username not found");
           ToastUtils.showCustomToast(context, "Username not found", false);
        }

        if (contents.contains("Login successful")) {

          showLoadingDialogue("Loading Data");

          if(loginas=="Driver") {
            Map<String, dynamic> updateMap = new Map<String, dynamic>.from(
                jsonDecode(contents));
            print(updateMap["Token"]);

            if(checkRemember) {
              await prefs.setString('UserToken', updateMap["Token"]);
            }
            DataStream.token = updateMap["Token"];

            final client = HttpClient();
            final request = await client.getUrl(Uri.parse(URLs.getDriverUrl()));
            request.headers.add("Authorization", "JWT " + DataStream.token);
            final response = await request.close();

            response.transform(utf8.decoder).listen((contents) async {
              //print(response.statusCode);
              Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
                  jsonDecode(contents));


              DataStream.driverProfile =
              new DriverProfile.fromJson(driverMap["Driver"]);
              ToastUtils.showCustomToast(context, "Sign In Success", true);
              hideLoadingDialogue();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DriverNavigationHomeScreen()),
                    (Route<dynamic> route) => false,
              );


            });
          }
          else if (loginas=="Trader"){

            Map<String, dynamic> updateMap = new Map<String, dynamic>.from(
                jsonDecode(contents));
            print(updateMap["Token"]);
            if(checkRemember) {
              await prefs.setString('UserToken', updateMap["Token"]);
            }


            DataStream.token = updateMap["Token"];

            final client = HttpClient();
            final request = await client.getUrl(Uri.parse(URLs.getTraderUrl()));
            request.headers.add("Authorization", "JWT " + DataStream.token);
            final response = await request.close();

            response.transform(utf8.decoder).listen((contents) async {
              //print(response.statusCode);
              Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
                  jsonDecode(contents));
              DataStream.traderProfile =
              new TraderProfile.fromJson(driverMap["Trader"]);
              hideLoadingDialogue();
              ToastUtils.showCustomToast(context, "Sign In Success", true);


              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TraderNavigationHomeScreen()),
                    (Route<dynamic> route) => false,
              );


            });



            }
          else if (loginas=="Broker"){

            Map<String, dynamic> updateMap = new Map<String, dynamic>.from(
                jsonDecode(contents));
            print(updateMap["Token"]);
            if(checkRemember) {
              await prefs.setString('UserToken', updateMap["Token"]);
            }

            DataStream.token = updateMap["Token"];

            final client = HttpClient();
            final request = await client.getUrl(Uri.parse(URLs.getTraderUrl()));
            request.headers.add("Authorization", "JWT " + DataStream.token);
            final response = await request.close();

            response.transform(utf8.decoder).listen((contents) async {
              print(contents);
              Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
                  jsonDecode(contents));
              DataStream.traderProfile =
              new TraderProfile.fromJson(driverMap["Trader"]);
              hideLoadingDialogue();
              ToastUtils.showCustomToast(context, "Sign In Success", true);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TraderNavigationHomeScreen()),
                    (Route<dynamic> route) => false,
              );

            });

          }
          else if (loginas=="Company"){

            Map<String, dynamic> updateMap = new Map<String, dynamic>.from(
                jsonDecode(contents));
            print(updateMap["Token"]);
            if(checkRemember) {
              await prefs.setString('UserToken', updateMap["Token"]);
            }

            DataStream.token = updateMap["Token"];

            final client = HttpClient();
            final request = await client.getUrl(Uri.parse(URLs.getTransportCompanyResponsibleURL()));
            request.headers.add("Authorization", "JWT " + DataStream.token);
            final response = await request.close();

            response.transform(utf8.decoder).listen((contents) async {
              //print(response.statusCode);
              Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
                  jsonDecode(contents));
              DataStream.transportCompanyResponsibleProfle =
              new TransportCompanyResponsibleProfle.fromJson(driverMap["TransportCompanyResponsible"]);
              hideLoadingDialogue();
              ToastUtils.showCustomToast(context, "Sign In Success", true);



              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CompanyNavigationHomeScreen()),
                    (Route<dynamic> route) => false,
              );

            });

          }
        }

      });
    }catch(e){
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      hideLoadingDialogue();

    }
  }

  String message = 'Log in/out by pressing the buttons below.';

  @override
  Widget build(BuildContext context) {
    Widget emailForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.account_circle),
       //   Image.asset("assets/icons/user-grey.png", height: 16.0, width: 16.0,),
          Container(
            width: screenWidth(context)*0.7,
            child: TextFormField(
              cursorColor: primaryDark, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
              keyboardType: TextInputType.emailAddress,
              onSaved: (String value) => email = value,
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter Your Username or Phone Number';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                labelText: "Username or Phone Number",
              ),
              focusNode: _focusNode,
            ),
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: new Border(
          bottom: BorderSide(color: _getBorderColor(), style: BorderStyle.solid, width: 2.0),
        ),
      ),
    );

    Widget passwordForm = Container(
      margin: EdgeInsets.only(bottom: 18.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.lock),

         // Image.asset("assets/icons/lock-grey.png", height: 16.0, width: 16.0,),
          Container(
            width: screenWidth(context)*0.68,
            child: TextFormField(
              cursorColor: primaryDark, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                onSaved: (String value) => password = value,
              validator: (String value) {
                if(value.isEmpty)
                  return 'Please Enter Your Password';
                else
                  return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                labelText: "Password",
              ),
              focusNode: _focusNode2,
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
          bottom: BorderSide(color: _getBorderColor2(), style: BorderStyle.solid, width: 2.0),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(

          child: Form(
            key: _formKey,
            child: Container(
              alignment: AlignmentDirectional.center,
              margin: EdgeInsets.only(top: 50.0),
              padding: const EdgeInsets.all(16.0),
              child: Column(
             //   padding: const EdgeInsets.all(16.0),

              //  physics: ScrollPhysics(),
                children: <Widget>[
                  Image.asset("assets/icons/logo.png", width: 200.0, height: 180.0, fit: BoxFit.contain,),
                  Container(
                    alignment: AlignmentDirectional.center,
                    padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                    child: Text("Sign In", style: TextStyle(fontSize: 32),),
                  ),
                  Container(
                    alignment: AlignmentDirectional.center,
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text("Sign In to your naqelapp Account",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    padding: EdgeInsets.only(left: 16.0, top: 28.0, bottom: 4.0, right: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Email"),
                        SizedBox(height: 10,),
                        emailForm,
                        Text("Password", ),
                        SizedBox(height: 10,),
                        passwordForm,
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: loginas,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Color(0x00000000),
                    ),
                    onChanged: (String data) {
                      setState(() {
                        loginas = data;
                      //  Navigator.of(context).pop();
                     //   _displayJobRequestDialog(context);


                      });
                    },
                    items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(value)),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            activeColor: primaryDark,
                            value: checkRemember,
                            onChanged: (bool value) {
                              setState(() {
                                checkRemember = value;
                              });
                            },
                          ),
                          Text("Remember me",),
                        ],
                      ),
                      FlatButton(
                        onPressed: (){
                          ToastUtils.showCustomToast(context, "Under Development \n Use existing account to login", null);

                       //   Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => ForgotPassword(), ),);
                        },
                        child: Text("Forgot password?"),
                      )
                    ],
                  ),
                  SizedBox(
                    width:200,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),

                      ),

                      color: primaryDark,
                      onPressed: () async {
                     //   await loginUser();
                        signin();
                      },
                      child: Text( "SIGN IN",style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    onPressed: (){

                     //  ToastUtils.showCustomToast(context, "Under Development \n Use existing account to login", null);

                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUp()));

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Dont't have an Account? ",),
                        Text("Sign up here",style: TextStyle(decoration: TextDecoration.underline,),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
