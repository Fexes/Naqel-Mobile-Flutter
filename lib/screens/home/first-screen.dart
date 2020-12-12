import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:naqelapp/models/TransportCompany/CompanyProfle.dart';
import 'package:naqelapp/models/driver/DriverProfile.dart';
import 'package:naqelapp/models/trader/TraderProfile.dart';
import 'package:naqelapp/screens/home/trader/trader_navigation_home_screen.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:naqelapp/utilts/URLs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'TransportCompany/company_navigation_home_screen.dart';
import 'driver/driver_navigation_home_screen.dart';
import '../auth/sign-in.dart';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {

  String UserToken;
  String loginas;
  @override
  void initState() {
    super.initState();

    loadData();
  }

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
  Dialog loadingdialog;
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


  Future<Timer> loadData() async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserToken =prefs.getString("UserToken");
    loginas =prefs.getString("LoginType");



    if(UserToken==null||UserToken ==""){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignIn()));

    }else{
     // showLoadingDialogue("Loading Data");
      print(UserToken);

      if(loginas=="Driver") {

        await prefs.setString('UserToken', UserToken);

        DataStream.token = UserToken;

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(URLs.getDriverUrl()));
          request.headers.add("Authorization", "JWT " + DataStream.token);
          final response = await request.close();

          response.transform(utf8.decoder).listen((contents) async {
            //print(response.statusCode);
            print(contents);
            Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
                jsonDecode(contents));


            DataStream.driverProfile =
            new DriverProfile.fromJson(driverMap["Driver"]);
            // ToastUtils.showCustomToast(context, "Sign In Success", true);
            hideLoadingDialogue();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DriverNavigationHomeScreen()),
                  (Route<dynamic> route) => false,
            );
          });
        }catch(e){
          error=true;
        }
      }
      else if (loginas=="Trader"){


        await prefs.setString('UserToken', UserToken);

        DataStream.token = UserToken;

        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(URLs.getTraderUrl()));
        request.headers.add("Authorization", "JWT " + DataStream.token);
        final response = await request.close();

        response.transform(utf8.decoder).listen((contents) async {
          //print(response.statusCode);
          print(contents);
          Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
              jsonDecode(contents));
          DataStream.traderProfile =
          new TraderProfile.fromJson(driverMap["Trader"]);
          hideLoadingDialogue();
        //  ToastUtils.showCustomToast(context, "Sign In Success", true);


          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TraderNavigationHomeScreen()),
                (Route<dynamic> route) => false,
          );


        });



      }
      else if (loginas=="Broker"){


        await prefs.setString('UserToken', UserToken);

        DataStream.token = UserToken;

        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(URLs.gettransportCompanyResponsiblesURL()));
        request.headers.add("Authorization", "JWT " + DataStream.token);
        final response = await request.close();

        response.transform(utf8.decoder).listen((contents) async {
          print(contents);
          Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
              jsonDecode(contents));
          DataStream.traderProfile =
          new TraderProfile.fromJson(driverMap["Trader"]);
          hideLoadingDialogue();
       //  ToastUtils.showCustomToast(context, "Sign In Success", true);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TraderNavigationHomeScreen()),
                (Route<dynamic> route) => false,
          );


        });

      }
      else if (loginas=="TC Responsible"){

        await prefs.setString('UserToken', UserToken);

        DataStream.token = UserToken;

        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(URLs.getTransportCompanyResponsibleURL()));
        request.headers.add("Authorization", "JWT " + DataStream.token);
        final response = await request.close();

        response.transform(utf8.decoder).listen((contents) async {
           print(contents);
          Map<String, dynamic> driverMap = new Map<String, dynamic>.from(
              jsonDecode(contents));
          DataStream.transportCompanyResponsibleProfle =
          new TransportCompanyResponsibleProfle.fromJson(driverMap["TransportCompanyResponsible"]);
          hideLoadingDialogue();
        //  ToastUtils.showCustomToast(context, "Sign In Success", true);



          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CompanyNavigationHomeScreen()),
                (Route<dynamic> route) => false,
          );

        });

      }

     }
}

bool error=false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0xffF7F7F7),
      child: Container(
          padding: EdgeInsets.all(100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/icons/logo.png", ),
              SizedBox(height: 200,),
              error?
              SizedBox(
                width:200,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),

                  ),

                  color: primaryDark,
                  onPressed: () async {
                    error=false;
                    loadData();
                    setState(() {

                    });
                  },
                  child: Text( "Retry",style: TextStyle(color: Colors.white),),
                ),
              ):
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
            ],
          )),
        // color

    );
  }



}

