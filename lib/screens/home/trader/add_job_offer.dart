import 'dart:async';
 import 'dart:io';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
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

class AddJobOffer extends StatefulWidget  {


  const AddJobOffer({Key key}) : super(key: key);



  @override
  _AddJobOfferState createState() => _AddJobOfferState();
}

class _AddJobOfferState extends State<AddJobOffer>  {

  FocusNode focusNodeloadingPlace,focusNodeunloadingPlace,focusNodePrice ,focusNodeCargoType,focusNodeWeight,focusNodeDelay,focusNodeWaitingTime;
  final priceController = TextEditingController();
  final delayController = TextEditingController();
  final LoadingPlaceController = TextEditingController();
  final UnloadingController = TextEditingController();

  DateTime temp ;
  bool EntryExitbol=false;
  BuildContext context;
  String googleAPIKey = "AIzaSyDezgtwvxs_HZGG8Dlkbt4Bi4IGymlvUnM";
  LatLng userPosition;
  bool checkenteryrxit = false;

  String TripType, CargoType, CargoWeight, LoadingPlace, UnloadingPlace, LoadingDate, LoadingTime, Price, AcceptedDelay, JobOfferType;
  String LoadingLat;
  String LoadingLng;
  String UnloadingLat;
  String UnloadingLng;

  String dropdownValue = 'One Way';

  List <String> spinnerItems = [
    'One Way',
    'Two Way',
  ] ;
  LatLng loadinglatlon,unloadinglatlon;

  @override
  void initState() {
    super.initState();

    focusNodeloadingPlace = new FocusNode();
    focusNodeloadingPlace.addListener(_onOnFocusNodeEvent);

    focusNodeunloadingPlace = new FocusNode();
    focusNodeunloadingPlace.addListener(_onOnFocusNodeEvent);


    focusNodePrice = new FocusNode();
    focusNodePrice.addListener(_onOnFocusNodeEvent);

    focusNodeWaitingTime = new FocusNode();
    focusNodeWaitingTime.addListener(_onOnFocusNodeEvent);



    focusNodeCargoType = new FocusNode();
    focusNodeCargoType.addListener(_onOnFocusNodeEvent);

    focusNodeWeight = new FocusNode();
    focusNodeWeight.addListener(_onOnFocusNodeEvent);

    focusNodeDelay = new FocusNode();
    focusNodeDelay.addListener(_onOnFocusNodeEvent);

    setSelectedRadio(1);


    // Future.wait([loadjobOffers(), loadjobRequests(), loadonGoingJob(),loadCompletedJob()])
    //     .catchError((e) {
    //   print(e);
    //
    // });


  }
  @override
  void dispose() {
    super.dispose();
   }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }




  @override
  Widget build(BuildContext context) {
    this.context=context;


    return Align(


        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(
                color: Colors.black
            ),

            title:   Text('Add Job Offer',style: TextStyle(color: Colors.black),),




          ),
          backgroundColor: Color(0xffF7F7F7),
          body: SingleChildScrollView(
            child:  Container(
              padding: EdgeInsets.only(
                top:  16.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              margin: EdgeInsets.only(top: 10.0),

              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.start,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: <Widget>[



                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.file_upload),
                          Container(
                            width: screenWidth(context)*0.7,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.text,
                              controller: LoadingPlaceController,
                              onTap:()  {

                                addLoadLocation();

                              },
                              onChanged: (String value) {
                                if(!value.isEmpty)
                                  LoadingPlace = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Loading Place';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Loading Place",

                              ),
                              focusNode: focusNodeloadingPlace,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: focusNodeloadingPlace.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                        ),
                      ),
                    ),
                    //  SizedBox(height: 16.0),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.file_download),
                          Container(
                            width: screenWidth(context)*0.7,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.text,

                              controller:UnloadingController,
                              onTap: ()  {

                                addUnloadLocation();

                              },
                              onChanged: (String value) {
                                if(!value.isEmpty)
                                  UnloadingPlace = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Unloading Place';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Unloading Place",

                              ),
                              focusNode: focusNodeunloadingPlace,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: focusNodeunloadingPlace.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                          BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                        ),
                      ),
                    ),
                    // SizedBox(height: 16.0),




                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 18.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                  decoration:BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(

                                      padding: EdgeInsets.all(5),
                                      child: Text("SR",style: TextStyle(color: Colors.white,fontSize: 13),))),

                              Container(
                                width: screenWidth(context)*0.25,
                                child: TextFormField(
                                  controller: priceController,
                                  cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                  keyboardType: TextInputType.number,
                                  //  initialValue: Price,
                                  onChanged: (String value) {
                                    if(!value.isEmpty)
                                      Price = value;
                                  },
                                  validator: (String value) {
                                    if(value.length == null)
                                      return 'Enter Price';
                                    else
                                      return null;
                                  },

                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),

                                    labelText: "Price",

                                  ),
                                  focusNode: focusNodePrice,
                                ),
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: focusNodePrice.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                              BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          margin: EdgeInsets.only(bottom: 18.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.shopping_basket),
                              Container(
                                width: screenWidth(context)*0.25,
                                child: TextFormField(
                                  cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                  keyboardType: TextInputType.number,
                               //   initialValue: CargoType,
                                  onChanged: (String value) {
                                    if(!value.isEmpty)
                                      CargoType = value;
                                  },
                                  validator: (String value) {
                                    if(value.length == null)
                                      return 'Enter Cargo Type';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),

                                    labelText: "Cargo Type",

                                  ),
                                  focusNode: focusNodeCargoType,
                                ),
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: focusNodeCargoType.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                              BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: <Widget>[

                        Container(
                          margin: EdgeInsets.only(bottom: 18.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.card_travel),
                              Container(
                                width: screenWidth(context)*0.25,
                                child: TextFormField(
                                  cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                  keyboardType: TextInputType.number,
                                 // initialValue: CargoWeight,
                                  onChanged: (String value) {
                                    if(!value.isEmpty)
                                      CargoWeight = value;
                                  },
                                  validator: (String value) {
                                    if(value.length == null)
                                      return 'Enter Cargo Weight';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),

                                    labelText: "Weight",

                                  ),
                                  focusNode: focusNodeWeight,
                                ),
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: focusNodeWeight.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                              BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          margin: EdgeInsets.only(bottom: 18.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.timer),
                              Container(
                                width: screenWidth(context)*0.25,
                                child: TextFormField(
                                  cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                  keyboardType: TextInputType.text,
                              //    initialValue: AcceptedDelay,
                                  controller: delayController,

                                  validator: (String value) {
                                    if(value.length == null)
                                      return 'Enter Accepted Delay';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),

                                    labelText: "Delay",

                                  ),
                                  focusNode: focusNodeDelay,
                                ),
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: focusNodeDelay.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                              BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 16.0),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,

                       children: <Widget>[

                         Container(
                           margin: EdgeInsets.only(bottom: 18.0),
                           child: Row(
                             children: <Widget>[
                               Icon(Icons.timelapse),
                               Container(
                                 width: screenWidth(context)*0.25,
                                 child: TextFormField(
                                   cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                   keyboardType: TextInputType.number,
                                   initialValue: CargoWeight,
                                   onChanged: (String value) {
                                     if(!value.isEmpty)
                                       CargoWeight = value;
                                   },
                                   validator: (String value) {
                                     if(value.length == null)
                                       return 'Enter Waiting time';
                                     else
                                       return null;
                                   },
                                   decoration: InputDecoration(
                                     contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                     border: OutlineInputBorder(
                                         borderSide: BorderSide.none
                                     ),

                                     labelText: "Waiting time",

                                   ),
                                   focusNode: focusNodeWaitingTime,
                                 ),
                               ),
                             ],
                           ),
                           decoration: new BoxDecoration(
                             border: new Border(
                               bottom: focusNodeWaitingTime.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                               BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                             ),
                           ),
                         ),
                       ],
                     ),
                    Container(
                      height: 115,
                      width: screenWidth(context)*0.7,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10,),
                          Text("Loading Date and Time",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                          SizedBox(height: 20,),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: temp,
                              onDateTimeChanged: (data){
                                temp=data;
                                LoadingDate=data.toIso8601String().split("T")[0];
                                //    loadingdate="${data.day}-${data.month}-${data.year}";
                                LoadingTime=data.toIso8601String().split("T")[1];
                              },

                            ),
                          ),
                        ],
                      ),
                    ),


                    Row(
                      children: <Widget>[
                        Checkbox(
                          activeColor: primaryDark,
                          value: EntryExitbol,
                          onChanged: (bool value) {
                            EntryExitbol = value;
                            setState(() {
                              
                            });
                            //     Navigator.of(context).pop();
                            //   _displayJobOfferDialog(context);

                          },
                        ),
                        Text("Entery / Exit ",),
                      ],
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DropdownButton<String>(
                          value: dropdownValue,
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
                              //  Navigator.of(context).pop();
                              dropdownValue = data;
                              TripType=dropdownValue;
                              //     _displayJobOfferDialog(context);


                            });
                          },
                          items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),

                      ],
                    ),

                     ButtonBar(
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
                           child: Text("Fixed Price"),
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
                           child: Text("Auctionable"),
                           onTap: () {setSelectedRadio(2);},
                         ),


                       ],
                     ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                           //   TripType= CargoType= CargoWeight= LoadingPlace= UnloadingPlace= LoadingDate= LoadingTime= Price= AcceptedDelay= JobOfferType="";
                              priceController.text="";
                              Navigator.of(context).pop(); // To close the dialog
                            },
                            child: Text("Dismiss"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                          //    Navigator.of(context).pop();
                              //  pr.show();

                              AcceptedDelay=delayController.text;
                              Price = priceController.text;


                              addjobOffer();
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
          ),

        ),

    );
  }

  Future<void> addLoadLocation() async {

    LocationResult result = await showLocationPicker(
      context,
      googleAPIKey,
    //  initialCenter: userPosition,
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,

    );
    print("result = $result");
    if(result!=null){
      LoadingPlace = result.address;
      LoadingLat=result.latLng.latitude.toString();
      LoadingLng=result.latLng.longitude.toString();

      LoadingPlaceController.text=LoadingPlace;

    //  Navigator.of(context).pop();

     }
    setState(() {

    });
  }

  Future<void> addUnloadLocation() async {

    LocationResult result = await showLocationPicker(
      context,
      googleAPIKey,
   //   initialCenter:,
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,

    );
    print("result = $result");
    if(result!=null){
      UnloadingPlace = result.address;
      UnloadingLat=result.latLng.latitude.toString();
      UnloadingLng=result.latLng.longitude.toString();

      UnloadingController.text=UnloadingPlace;


     }
    setState(() {

    });
  }
  int selectedRadio;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
      switch (val){
        case 1:
          JobOfferType="Fixed-Price";
          break;
        case 2:
          JobOfferType="Auctionable";
          break;

      }
    });
  }

  Future<void> addjobOffer() async {

    showLoadingDialogue("Adding Job Offer");
    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.addJobOfferURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);



    //  JobOfferType=   "Fixed-Price";
  //    TripType="Two Way";
  //    CargoType = "Bookssss";
//      AcceptedDelay = "2";


      // users/getTruckSizes
      // users/getTruckTypes
      // users/getWaitingTimes
      // users/getPermitTypes

      int ee;
      checkenteryrxit?ee=1:ee=0;

        //TripType, CargoType, CargoWeight,
        // DriverNationalities, TruckTypes, TruckSizes, PermitType,WaitingTime,
        // LoadingPlace,
        // LoadingLat, LoadingLng, UnloadingPlace, UnloadingLat, UnloadingLng, LoadingDate, LoadingTime,
        // EntryExit, Price,  AcceptedDelay, JobOfferType

      request.write(
          '{"TripType": "$TripType","CargoType": "$CargoType","CargoWeight": "$CargoWeight",'
              '"LoadingPlace": "$LoadingPlace","UnloadingPlace": "$UnloadingPlace","LoadingDate": "'+LoadingDate+'",'
              '"LoadingTime": "'+LoadingTime+'","EntryExit": "$ee","Price": "$Price",'
              '"AcceptedDelay": "$AcceptedDelay","JobOfferType": "$JobOfferType"'
              ',"LoadingLat": "$LoadingLat","LoadingLng": "$LoadingLng"'

              ',"DriverNationalities": "Any Nationality","TruckTypes": "Any Truck Type"'
              ',"TruckSizes": "Any Truck Size","PermitType": "Single"'
              ',"WaitingTime": "2"'

              ',"UnloadingLat": "$UnloadingLat","UnloadingLng": "$UnloadingLng"}');

      final response = await request.close();



      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        hideLoadingDialogue();
        Navigator.pop(context);


      });
    }catch(e){

      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
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


}
