import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:naqelapp/models/commons/CompletedJob.dart';
import 'package:naqelapp/models/driver/jobs/JobOfferPosts.dart';
import 'package:naqelapp/models/commons/OngoingJob.dart';
import 'package:naqelapp/models/trader/jobs/DriverRequestPackages.dart';
import 'package:naqelapp/models/trader/jobs/JobOfferTrader.dart';
import 'package:naqelapp/models/trader/jobs/JobRequestPosts.dart';
import 'package:naqelapp/screens/auth/forgot-password.dart';
import 'package:naqelapp/screens/auth/sign-in.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/utilts/UI/ScrollingText.dart';
import 'package:naqelapp/utilts/URLs.dart';
import 'package:naqelapp/models/driver/DriverProfile.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naqelapp/utilts/UI/panel.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
 import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
 import 'package:rating_bar/rating_bar.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:http/http.dart' as http;

import 'add_job_offer.dart';





class TraderHomePage extends StatefulWidget {
  const TraderHomePage({Key key}) : super(key: key);

  @override
  _TraderHomePageState createState() => _TraderHomePageState();
}
class _TraderHomePageState extends State<TraderHomePage>  {
  ScrollController _controllerddd = ScrollController();

   Completer<GoogleMapController> _controller = Completer();
  static LatLng latLng =LatLng(0, 0,);
   PanelController _pc = new PanelController();
  List<JobRequestPosts>  jobRequests;
  List<JobOfferPackages>  jobOffers;
  List<CompletedJobPackages>  compleatedJobs;
  List<DriverRequestPackages>  driverrRequestPackages;

  OngoingJob ongoingJob;
  LocationResult _pickedLocation;


   double CAMERA_ZOOM = 13;
   double CAMERA_TILT = 0;
   double CAMERA_BEARING = 30;
 // this set will hold my markers
  Set<Marker> _markers = {};
// this will hold the generated polylines
  Set<Polyline> _polylines = {};
// this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
// this is the key object - the PolylinePoints
// which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

// for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  String googleAPIKey = "AIzaSyDezgtwvxs_HZGG8Dlkbt4Bi4IGymlvUnM";


  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/twitter.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/twitter.png');
  }
  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    Future
        .wait([loadjobOffers(), loadjobRequests(), loadonGoingJob(),loadCompletedJob()])
        .catchError((e) => print(e));
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: new LatLng(ongoingJob.LoadingLat, ongoingJob.LoadingLng),
          icon: sourceIcon
      ));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position:  new LatLng(ongoingJob.UnloadingLat, ongoingJob.UnloadingLng),
          icon: destinationIcon
      ));


    });
  }
  setPolylines() async {
    List<PointLatLng> result = await
    polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        ongoingJob.LoadingLat,
        ongoingJob.LoadingLng,
        ongoingJob.UnloadingLat,
        ongoingJob.UnloadingLng);
    if(result.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point){
        polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates
      );


      _polylines.add(polyline);
    });
  }
  int tab_postion=0;
 bool fab_visible = false;
  @override
  void initState(){
    super.initState();
    _fabHeight = _initFabHeight;

    focusNodeloadingPlace = new FocusNode();
    focusNodeloadingPlace.addListener(_onOnFocusNodeEvent);

    focusNodeunloadingPlace = new FocusNode();
    focusNodeunloadingPlace.addListener(_onOnFocusNodeEvent);


    focusNodePrice = new FocusNode();
    focusNodePrice.addListener(_onOnFocusNodeEvent);

    getLocation();




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


  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }
  int driver_requests_number=0;
   bool jobRequestsloaded=false;
  Future<void> loadjobRequests() async {

    showLoadingDialogue("Loading");
    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getJobRequestPostsURL(), headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);

        //   print(contents);
        if(jobRequestsMap["JobRequestPosts"]!= null) {

          DataStream.traderJobRequestPosts =DataStream.parsetraderJobRequestPosts(jobRequestsMap["JobRequestPosts"]);
          print(jobRequestsMap["JobRequestPosts"]);
          jobRequests = DataStream.traderJobRequestPosts;


        }

        hideLoadingDialogue();
        jobRequestsloaded=true;

        setState(() {
        });


      }



    }catch(e){
       print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);

    }


  }
  bool jobOfferloaded=false;

  Future<void> loadjobOffers() async {

    showLoadingDialogue("Loading");

    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getTraderJobOfferPostsURL(), headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> map = convert.jsonDecode(response.body);
         if(map["JobOfferPackages"]!= null) {
          DataStream.traderJobOfferPackages =
              DataStream.parsetraderJobOfferPackages(map["JobOfferPackages"]);

          jobOffers = DataStream.traderJobOfferPackages;

        }
        driver_requests_number=0;
        for(int i=0;i<=jobOffers.length-1;i++){
          driver_requests_number=driver_requests_number+jobOffers[i].jobOfferTrader.NumberOfDriverRequests;
        }
        hideLoadingDialogue();
        jobOfferloaded=true;
        setState(() {
        });

      }



    }catch(e){
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);

    }

  }


  bool CompletedJobloaded=false;

  Future<void> loadCompletedJob() async {
    showLoadingDialogue("Loading");
    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.tradergetCompletedJobPackagesURL(), headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> map = convert.jsonDecode(response.body);

        if (map["CompletedJobPackages"] != null) {
          DataStream.compleatedJobspackage =
              DataStream.parseCompletedJobs(map["CompletedJobPackages"]);
          print(map["CompletedJobPackages"]);
          compleatedJobs = DataStream.compleatedJobspackage;
        }
        hideLoadingDialogue();
        CompletedJobloaded = true;


        setState(() {
        });

      }



    }catch(e){
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);

    }

  }


  bool onGoingJobloaded=false;
  bool isonJob=false;
  String onGoingDriverLocation="";
  Future<void> loadonGoingJob() async {

    showLoadingDialogue("Loading");
    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.gettradersOnGoingJobURL(), headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> map = convert.jsonDecode(response.body);

         if(map["OnGoingJob"]!= null) {
          DataStream.ongoingJob =
          new OngoingJob.fromJson(map["OnGoingJob"]);
          print(map["OnGoingJob"]);
          ongoingJob = DataStream.ongoingJob;
          isonJob=true;

          setMapPins();
          setPolylines();

          final locationDbRef = FirebaseDatabase.instance.reference().child("${ongoingJob.DriverID}");

          locationDbRef.once().then((value) async {
            print("asasdasdsad");
            print(value.value.toString());
            onGoingDriverLocation = value.value["latlong"];
            final GoogleMapController controller = await _controller.future;

            LatLng driverLocation = new LatLng(
                double.parse(onGoingDriverLocation.split(',')[0]),
                double.parse(onGoingDriverLocation.split(',')[1]));
            _addDriverPin(driverLocation, controller);

          }
          );


          locationDbRef.onChildChanged.listen((event) async {
            if (isonJob) {
              print(event.snapshot.value);
              onGoingDriverLocation = event.snapshot.value;
              final GoogleMapController controller = await _controller.future;

              LatLng driverLocation = new LatLng(
                  double.parse(onGoingDriverLocation.split(',')[0]),
                  double.parse(onGoingDriverLocation.split(',')[1]));
              _addDriverPin(driverLocation, controller);
            } else {
              locationDbRef.keepSynced(false);
            }
          });

        }


        hideLoadingDialogue();
        onGoingJobloaded=true;
        setState(() {
        });

      }



    }catch(e){
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);

    }


  }
  LatLng userPosition;
   Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS

  Future<void> getLocation() async {


    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.location,
    // ].request();


    PanelController _pc = new PanelController();
    var geolocator = Geolocator();
    GeolocationStatus geolocationStatus =
    await geolocator.checkGeolocationPermissionStatus();
    switch (geolocationStatus) {
      case GeolocationStatus.denied:
        print('denied');
        break;
      case GeolocationStatus.disabled:
        print('disabled');break;
      case GeolocationStatus.restricted:
        print('restricted');
        break;
      case GeolocationStatus.unknown:
        print('unknown');
        break;
      case GeolocationStatus.granted:
     //   print('granted');

        await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position _position) async {
          if (_position != null) {

            userPosition = LatLng(_position.latitude, _position.longitude);
            final GoogleMapController controller = await _controller.future;

            _add(userPosition,controller);

            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: userPosition,
                    bearing: 0,
                    zoom: 15),
              ),

            );
            setState((){
            });
          }
        });
        break;
    }
  }

   Future<void> _add(LatLng p,GoogleMapController controller) async {


     var markerIdVal = "Location";
     final MarkerId markerId = MarkerId(markerIdVal);

     // creating a new MARKER
     final Marker marker = Marker(
         icon: await getMarkerIcon( Size(150.0, 150.0),DataStream.traderProfile.PhotoURL),
   //   icon: BitmapDescriptor.fromBytes(markerImageBytes),
       markerId: markerId,
       infoWindow: InfoWindow(title: '${ DataStream.traderProfile.FirstName} ${ DataStream.traderProfile.LastName}' ),

       position: LatLng(
         p.latitude ,
         p.longitude ,
       ),
 //      infoWindow: InfoWindow(title: markerIdVal, snippet: 'click for details',onTap: (){
   //      print("Marker Window Tap");
     //  }),
       onTap: () {
         print("Marker Tap");

        },
     );

     setState(() {
       // adding a new marker to map
       markers[markerId] = marker;

       _markers.add(marker);
     });
   }

bool trackDriver=false;
  Future<void> _addDriverPin(LatLng p,GoogleMapController controller) async {


    var markerIdVald = "LocationDriver";
    final MarkerId markerIdd = MarkerId(markerIdVald);

    // creating a new MARKER
    final Marker markerd = Marker(
      icon: await getMarkerIcon( Size(150.0, 150.0),DataStream.ongoingJob.driver.PhotoURL),
      //   icon: BitmapDescriptor.fromBytes(markerImageBytes),
      markerId: markerIdd,
      infoWindow: InfoWindow(title: '${ DataStream.ongoingJob.driver.FirstName} ${ DataStream.ongoingJob.driver.LastName}' ),
      position: LatLng(
        p.latitude ,
        p.longitude ,
      ),
      //      infoWindow: InfoWindow(title: markerIdVal, snippet: 'click for details',onTap: (){
      //      print("Marker Window Tap");
      //  }),
      onTap: () {
        print("Marker Tap");

      },
    );

    setState(() {
      // adding a new marker to map
    //  markers[markerId] = marker;

      if(trackDriver) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: p,
                bearing: 0,
                zoom: 18),
          ),
        );
      }

      print("marker added");
      _markers.add(markerd);
    });
  }

   final double _initFabHeight = 160.0;
   double _fabHeight;
   double _panelHeightOpen;
   double _panelHeightClosed = 130.0;
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

  }
   IconData fab_icon = Icons.gps_fixed;

    @override
  Widget build(BuildContext context) {


      CameraPosition initialLocation = CameraPosition(
          zoom: 5,
          bearing: CAMERA_BEARING,
          tilt: CAMERA_TILT,
          target: new LatLng(23.8859, 45.0792)
      );



      _panelHeightOpen = MediaQuery.of(context).size.height * .80;

      return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Stack(
           children: <Widget>[

            Positioned(
              right: 5,
              child: GestureDetector(
                  onTap: (){
                 //   UpdateTokenData(context);
                    print("reload");
                    Future
                        .wait([loadjobOffers(), loadjobRequests(), loadonGoingJob(),loadCompletedJob()])
                        .catchError((e) => print(e));
                  },
                  child: Icon(Icons.sync,color: Colors.grey[700],size: 22,)),
            ),


             Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:<Widget>[
                    Text('Jobs',style: TextStyle(color: Colors.black),),

                  ]
              ),

          ],

        ),
      ),
      body: Stack(
        children: <Widget>[



          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            controller: _pc,
            parallaxOffset: .5,

            collapsed: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(28.0), topRight: Radius.circular(28.0)),
              ),
              child: Column(
                children: <Widget>[
                     Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(

                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(height: 10.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 30,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.all(Radius.circular(12.0))
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.0,),

                          ],
                        ),
                      ],
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[

                          GestureDetector(
                        onTap: (){
                          print("Requests clicker");

                          tab_postion=1;
                          _pc.open();
                         // loadjobRequests();

                          setState(() {

                          });
                        },
                        child:

                        jobRequests!=null?
                        Column(
                        children: <Widget>[


                          jobRequestsloaded&&jobRequests.length>0?
                          Badge(
                            badgeColor: tab_postion==1||tab_postion==0?Colors.blue[900]:Colors.grey[700],
                            badgeContent: Padding(
                                padding: EdgeInsets.all(5.0),
                            child: Text('${jobRequests.length}',style: TextStyle(color: Colors.white),)),

                            child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                    child: Icon( Icons.work,color: Colors.white,),
                                   decoration: BoxDecoration(
                                   color: tab_postion==1||tab_postion==0?Colors.blue[400]:Colors.grey,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    blurRadius: 8.0,
                                  )]
                                ),
                              ),
                          ):Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon( Icons.work,color: Colors.white,),
                            decoration: BoxDecoration(
                                color: tab_postion==1||tab_postion==0?Colors.blue[400]:Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 8.0,
                                )]
                            ),
                          ),

                         SizedBox(height: 8.0,),

                         Text("Requests",style: TextStyle(color: tab_postion==1||tab_postion==0?Colors.blue[600]:Colors.grey),),
                            ],

                          ):
                        Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon( Icons.work,color: Colors.white,),
                              decoration: BoxDecoration(
                                  color: tab_postion==1||tab_postion==0?Colors.blue[400]:Colors.grey,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.15),
                                    blurRadius: 8.0,
                                  )]
                              ),
                            ),

                            SizedBox(height: 8.0,),

                            Text("Requests",style: TextStyle(color: tab_postion==1||tab_postion==0?Colors.blue[600]:Colors.grey),),
                          ],

                        ),
                      ),
                          GestureDetector(
                            onTap: (){
                              print("offers clicker");
                              tab_postion=2;
                          //    loadjobOffers();
                              _pc.open();
                              setState(() {

                              });
                            },
                            child: Column(
                              children: <Widget>[

                                driver_requests_number!=0?
                                Badge(
                                  badgeColor: tab_postion==2||tab_postion==0?Colors.amber[900]:Colors.grey[700],
                                  badgeContent:Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(driver_requests_number.toString(),style: TextStyle(color: Colors.white),)),

                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon( Icons.card_giftcard,color: Colors.white,),
                                    decoration: BoxDecoration(
                                        color: tab_postion==2||tab_postion==0?Colors.amber[500]:Colors.grey,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 8.0,
                                        )]
                                    ),
                                  ),
                                ):Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon( Icons.card_giftcard,color: Colors.white,),
                                  decoration: BoxDecoration(
                                      color: tab_postion==2||tab_postion==0?Colors.amber[500]:Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8.0,
                                      )]
                                  ),
                                ),

                                SizedBox(height: 8.0,),

                                Text("Offers",style: TextStyle(color: tab_postion==2||tab_postion==0?Colors.amber[700]:Colors.grey),),
                              ],

                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              print("on-going clicker");

                            //  loadonGoingJob();
                              tab_postion=3;
                              _pc.open();
                              setState(() {

                              });
                            },
                            child: Column(
                              children: <Widget>[

                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon( Icons.hourglass_full,color: Colors.white,),
                                  decoration: BoxDecoration(
                                      color:tab_postion==3||tab_postion==0?Colors.deepPurpleAccent[100]:Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8.0,
                                      )]
                                  ),
                                ),

                                SizedBox(height: 8.0,),

                                Text("On-Going",style: TextStyle(color: tab_postion==3||tab_postion==0?Colors.deepPurpleAccent[200]:Colors.grey),),
                              ],

                            ),

                          ),
                          GestureDetector(
                            onTap: (){
                              print("Compleated clicker");

                              tab_postion=4;
                           //   loadCompletedJob();
                              _pc.open();
                              setState(() {

                              });
                            },
                            child: Column(
                              children: <Widget>[

                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon( Icons.done_all,color: Colors.white,),
                                  decoration: BoxDecoration(
                                      color:tab_postion==4||tab_postion==0?Colors.green[400]:Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.15),
                                        blurRadius: 8.0,
                                      )]
                                  ),
                                ),

                                SizedBox(height: 8.0,),

                                Text("Compleated",style: TextStyle(color: tab_postion==4||tab_postion==0?Colors.green[600]:Colors.grey),),
                              ],

                            ),

                          ),
                     ],
                  ),
                ],
              ),
            ),

            body:  GoogleMap(

              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              onTap:(l){
                trackDriver=false;
              },
              compassEnabled: true,
              initialCameraPosition: initialLocation,
              onMapCreated: onMapCreated,
            //  initialCameraPosition: CameraPosition(target: latLng,zoom: 0,),
           //    markers: Set<Marker>.of(markers.values),
            ),

            onPanelOpened: (){
              if(tab_postion==2){
                fab_visible=true;
                setState(() {

                });
              }else{
                fab_visible=false;
              }
              fab_icon=Icons.arrow_downward;
              if(tab_postion==0){
                fab_visible=true;
                tab_postion=2;
            //    loadjobOffers();
              }
              setState(() {

              });
             },
            onPanelClosed: (){
              fab_visible=false;

              tab_postion=0;
              fab_icon=Icons.gps_fixed;
              try {
                list_sc.jumpTo(1);
              }catch(e){

              }
              setState(() {

              });
            },
            panelBuilder: (sc) => _panel(sc),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(28.0), topRight: Radius.circular(28.0)),
            onPanelSlide: (double pos) => setState((){
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
            }),
          ),

          Positioned(
            right: 20.0,
            bottom: _fabHeight-15,
            child: FloatingActionButton(
              child: Icon(
                fab_icon,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {

                trackDriver=false;


                getLocation();
               if( _pc.isPanelOpen){

                  fab_icon =Icons.gps_fixed;
                  _pc.close();
                  setState(() {

                 });

               }else {

               }
              },
              backgroundColor: Colors.white,
            ),
          ),

          Visibility(
            visible: ongoingJob!=null,
            child: Positioned(
              left:90.0,
              bottom: _fabHeight-15,
              child: FloatingActionButton(
                child: Icon(
                  Icons.call_split,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  trackDriver=true;

                  final GoogleMapController controller = await _controller
                      .future;
                  LatLng pathlocaton = new LatLng(ongoingJob.LoadingLat, ongoingJob.LoadingLng);


                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: pathlocaton,
                          bearing: 0,
                          zoom: 15),
                    ),

                  );
                  setState(() {});
                },
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: ongoingJob!=null,
            child: Positioned(
              left: 20.0,
              bottom: _fabHeight-15,
              child: FloatingActionButton(
                child: Icon(
                  Icons.directions_bus,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {

                  trackDriver=true;

                  final GoogleMapController controller = await _controller
                      .future;
                  LatLng driverLocation = new LatLng(double.parse(onGoingDriverLocation.split(',')[0]), double.parse(onGoingDriverLocation.split(',')[1]));


                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: driverLocation,
                          bearing: 0,
                          zoom: 15),
                    ),

                  );
                  setState(() {});
                },
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: fab_visible,
            child: Positioned(

                bottom: 15,
                right: 15,
                child:  FloatingActionButton(
                  heroTag: "offers",

                  onPressed: (){
                    if(driverrRequestPackagesloaded){
                      driverrRequestPackagesloaded=false;
                      setState(() {

                      });
                    }else{

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddJobOffer()),
                      );

                 //     _displayJobOfferDialog(context);
                    }

                  },
                  child:
                  driverrRequestPackagesloaded?
                  Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                  ):
                  Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  backgroundColor: Colors.white,
                ),
            ),
          ),
        ],
      ),


    );
  }
   Future<ui.Image> getImageFromPath(String url) async {

    final File imageFile = await DefaultCacheManager().getSingleFile(url);


 //    File imageFile = File(imagePath);

     Uint8List imageBytes = imageFile.readAsBytesSync();

     final Completer<ui.Image> completer = new Completer();

     ui.decodeImageFromList(imageBytes, (ui.Image img) {
       return completer.complete(img);
     });

     return completer.future;
   }

   Future<BitmapDescriptor> getMarkerIcon( Size size,String url) async {
     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
     final Canvas canvas = Canvas(pictureRecorder);

     final Radius radius = Radius.circular(size.width / 2);

     final Paint tagPaint = Paint()..color = Colors.blue;
     final double tagWidth = 40.0;

     final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
     final double shadowWidth = 15.0;

     final Paint borderPaint = Paint()..color = Colors.white;
     final double borderWidth = 3.0;

     final double imageOffset = shadowWidth + borderWidth;

     // Add shadow circle

     canvas.drawRRect(
         RRect.fromRectAndCorners(
           Rect.fromLTWH(
               0.0,
               0.0,
               size.width,
               size.height
           ),
           topLeft: radius,
           topRight: radius,
           bottomLeft: radius,
           bottomRight: radius,
         ),
         shadowPaint);

     // Add border circle
     canvas.drawRRect(
         RRect.fromRectAndCorners(
           Rect.fromLTWH(
               shadowWidth,
               shadowWidth,
               size.width - (shadowWidth * 2),
               size.height - (shadowWidth * 2)
           ),
           topLeft: radius,
           topRight: radius,
           bottomLeft: radius,
           bottomRight: radius,
         ),
         borderPaint);

  /*   // Add tag circle
     canvas.drawRRect(
         RRect.fromRectAndCorners(
           Rect.fromLTWH(
               size.width - tagWidth,
               0.0,
               tagWidth,
               tagWidth
           ),
           topLeft: radius,
           topRight: radius,
           bottomLeft: radius,
           bottomRight: radius,
         ),
         tagPaint);

     // Add tag text
     TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
   textPainter.text = TextSpan( text: '21', style: TextStyle(fontSize: 20.0, color: Colors.white),);

     textPainter.layout();
     textPainter.paint(
         canvas,
         Offset(
             size.width - tagWidth / 2 - textPainter.width / 2,
             tagWidth / 2 - textPainter.height / 2
         )
     );
 */
     // Oval for the image
     Rect oval = Rect.fromLTWH(
         imageOffset,
         imageOffset,
         size.width - (imageOffset * 2),
         size.height - (imageOffset * 2)
     );

     // Add path for oval image
     canvas.clipPath(Path()
       ..addOval(oval));

     // Add image
     ui.Image image = await getImageFromPath(url); // Alternatively use your own method to get the image
     paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.cover);

     // Convert canvas to image
     final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
         size.width.toInt(),
         size.height.toInt()
     );

     // Convert image to bytes
     final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
     final Uint8List uint8List = byteData.buffer.asUint8List();

     return BitmapDescriptor.fromBytes(uint8List);
   }


  ScrollController list_sc;
   Widget _panel(ScrollController sc){
     list_sc = sc;

     return MediaQuery.removePadding(
         context: context,
         removeTop: true,
         child: Stack(
           children: <Widget>[

             tab_postion==0?SizedBox():
             // Job Requests
             tab_postion==1?
             jobRequests!=null?

                 Padding(
                 padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),
                 child: jobRequests != null ? ListView.builder(
                     controller: list_sc,
                     itemCount: jobRequests.length,

                     itemBuilder: (BuildContext context, int index) {
                       return Padding(
                         padding: EdgeInsets.all(8),

                         child: Container(
                           decoration: BoxDecoration(
                               color: Colors.grey[100],
                               shape: BoxShape.rectangle,
                               borderRadius: new BorderRadius.only(
                                 topLeft: const Radius.circular(10.0),
                                 topRight: const Radius.circular(10.0),
                                 bottomLeft: const Radius.circular(10.0),
                                 bottomRight: const Radius.circular(10.0),
                               ),
                               boxShadow: [BoxShadow(
                                 color: Color.fromRGBO(0, 0, 0, 0.15),
                                 blurRadius: 8.0,
                               )
                               ]
                           ),
                           key: ValueKey(jobRequests[index]),
                           child:  Stack(
                                   children: <Widget>[

                                     Column(
                                       mainAxisAlignment: MainAxisAlignment
                                           .center,
                                       crossAxisAlignment: CrossAxisAlignment
                                           .center,
                                       children: <Widget>[
                                         SizedBox(height: 20),
                                         Text('${jobRequests[index].driver.FirstName} ${jobRequests[index].driver.LastName}',
                                           style: TextStyle(
                                             fontWeight: FontWeight.w300,
                                             color: AppTheme.grey,
                                             fontSize: 22,
                                           ),
                                         ),
                                         SizedBox(height: 10),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .start,
                                           crossAxisAlignment: CrossAxisAlignment
                                               .center,
                                           children: <Widget>[
                                             Container(
                                               height: 90,
                                               width: 90,
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
                                                 const BorderRadius.all(Radius.circular(60.0)),
                                                 child: jobRequests[index].driver.PhotoURL==null ? Icon(Icons.account_circle,color: Colors.grey,size: 0,) :  Image.network(jobRequests[index].driver.PhotoURL,fit: BoxFit.cover)
                                                 ,

                                               ),
                                             ),
                                             Column(
                                               children: <Widget>[
                                                 Row(
                                                       mainAxisAlignment: MainAxisAlignment
                                                           .start,
                                                       crossAxisAlignment: CrossAxisAlignment
                                                           .start,
                                                       children: <Widget>[
                                                         SizedBox(width: 10),
                                                         Column(
                                                           mainAxisAlignment: MainAxisAlignment
                                                               .start,
                                                           crossAxisAlignment: CrossAxisAlignment
                                                               .start,

                                                           children: <Widget>[



                                                             Row(
                                                               mainAxisAlignment: MainAxisAlignment.start,
                                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                               children: <Widget>[
                                                                 Icon(Icons.assessment,
                                                                   color: Colors.blueAccent, size: 25,),
                                                                 SizedBox(width: 5),
                                                                 Column(
                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: <Widget>[

                                                                     Text("Trip Type",
                                                                       style: TextStyle(
                                                                         color: AppTheme.grey,
                                                                         fontSize: 12,
                                                                       ),
                                                                     ),
                                                                     Text(
                                                                       '${jobRequests[index].jobRequestTrader.TripType}',
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
                                                                 Icon(Icons.location_on,
                                                                   color: Colors.blueAccent, size: 25,),
                                                                 SizedBox(width: 5),
                                                                 Column(
                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: <Widget>[

                                                                     Text("Loading ",
                                                                       style: TextStyle(
                                                                         color: AppTheme.grey,
                                                                         fontSize: 12,
                                                                       ),
                                                                     ),
                                                                     Container(
                                                                       width: 110,
                                                                       child: Text(
                                                                         '${jobRequests[index].jobRequestTrader.LoadingPlace}',
                                                                         maxLines: 4,
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
                                                             SizedBox(height: 10),



                                                           ],),

                                                         SizedBox(width: 10),

                                                         Column(

                                                           mainAxisAlignment: MainAxisAlignment
                                                               .start,
                                                           crossAxisAlignment: CrossAxisAlignment
                                                               .start,
                                                           children: <Widget>[



                                                             Row(
                                                               mainAxisAlignment: MainAxisAlignment.start,
                                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                               children: <Widget>[
                                                                 Icon(Icons.monetization_on,
                                                                   color: Colors.blueAccent, size: 25,),
                                                                 SizedBox(width: 5),
                                                                 Column(
                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: <Widget>[

                                                                     Text("Price",
                                                                       style: TextStyle(
                                                                         color: AppTheme.grey,
                                                                         fontSize: 12,
                                                                       ),
                                                                     ),
                                                                     Text(
                                                                       '${jobRequests[index].jobRequestTrader.Price}',
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
                                                                 Icon(Icons.location_on,
                                                                   color: Colors.blueAccent, size: 25,),
                                                                 SizedBox(width: 5),
                                                                 Column(
                                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: <Widget>[

                                                                     Text("UnLoading",
                                                                       style: TextStyle(
                                                                         color: AppTheme.grey,
                                                                         fontSize: 12,
                                                                       ),
                                                                     ),
                                                                     Container(
                                                                       width: 110,
                                                                       child: Text(
                                                                         '${jobRequests[index].jobRequestTrader.UnloadingPlace}',
                                                                         maxLines: 4,
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


                                               ],
                                             ),
                                           ],
                                         ),
                                         Row(
                                           crossAxisAlignment: CrossAxisAlignment.end,
                                           mainAxisAlignment: MainAxisAlignment.end,
                                           children: <Widget>[
                                             Align(
                                               alignment: Alignment.bottomCenter,
                                               child: FlatButton(
                                                 onPressed: () {
                                                   //   Navigator.of(context).pop();
                                                   viewDriver(jobRequests[index].jobRequestTrader.DriverID);

                                                 },
                                                 child: Text("Profile"),
                                               ),
                                             ),
                                             jobRequests[index].traderRequest==null?
                                             Align(
                                               alignment: Alignment.bottomCenter,
                                               child: FlatButton(
                                                 onPressed: () {
                                                   //   Navigator.of(context).pop();
                                                   addjobRequest(jobRequests[index].jobRequestTrader
                                                       .JobRequestID);

                                                 },
                                                 child: Text("Send Request"),
                                               ),
                                             ):
                                             Align(
                                               alignment: Alignment.bottomCenter,
                                               child: FlatButton(
                                                 onPressed: () {
                                                   //   Navigator.of(context).pop();
                                                   addjobRequest(jobRequests[index].jobRequestTrader
                                                       .JobRequestID);

                                                 },
                                                 child: Text("Cancel Request"),
                                               ),
                                             ),

                                             jobRequests[index].traderRequest!=null&&jobRequests[index].traderRequest.Selected==1?
                                             Align(
                                               alignment: Alignment.bottomCenter,
                                               child: FlatButton(
                                                 onPressed: () {
                                                   //   Navigator.of(context).pop();
                                                   addOnGoingJobFromJobRequest(jobRequests[index].traderRequest
                                                       .TraderRequestID);

                                                 },
                                                 child: Text("Assign Job"),
                                               ),
                                             ):SizedBox(),
                                           ],

                                         ),
                                       ],
                                     ),



                                     Positioned(

                                       right: 3,
                                       top: -5,
                                       child: InkWell(
                                         // When the user taps the button, show a snackbar.
                                         onTap: () {
                                           //     pr.show();

                                         },
                                         child: Container(
                                           padding: EdgeInsets.all(12.0),
                                           child: Column(
                                             children: <Widget>[
                                            /*   jobRequests[index].NumberOfTraderRequests>0?
                                               Badge(
                                                 badgeColor:Colors.blue[900],
                                                 shape: BadgeShape.circle,
                                                 borderRadius: 90,
                                                 toAnimate: false,
                                                 badgeContent: Padding(
                                                     padding: EdgeInsets.all(3.0),
                                                     child: Text('${jobRequests[index].NumberOfTraderRequests}',style: TextStyle(color: Colors.white),)),
                                                 child: Icon(Icons.more_horiz,
                                                   color: Colors.black, size: 30,),
                                               ):

                                             */
//                                            Icon(Icons.more_horiz,
//                                                 color: Colors.black, size: 30,),
//                                               Text("More",style: TextStyle(color: Colors.black),),

                                             ],
                                           ),
                                         ),
                                       ),
                                     ),

                                   ],
                                 ),

                         ),
                       );
                     }

                 ) : SizedBox(height: 1.0,),

               ):
                 jobRequestsloaded?
                 Container(
                     alignment: Alignment.center,
                     child: Text("No Job Requests found",style: TextStyle(color:Colors.blue[600]),)
                 ):
                 Container(
                     alignment: Alignment.center,
                     child: Text("Loading Requests",style: TextStyle(color:Colors.blue[600]),)
                 )
                 :
             tab_postion==2?
             jobOffers!=null?
             driverrRequestPackagesloaded?
             Padding(
               padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),

               child: ListView.builder(
                   controller: list_sc,
                   itemCount: driverrRequestPackages.length,

                   itemBuilder: (BuildContext context, int index) {
                     return   Column(
                       children: <Widget>[
                         index==0?
                         Column(
                           children: [
                             SizedBox(height: 16.0),
                             Text(
                               "Driver Requests",
                               style: TextStyle(
                                 fontSize: 24.0,
                                 fontWeight: FontWeight.w700,
                               ),
                             ),
                             SizedBox(height: 26.0),
                           ],
                         ):SizedBox(),

                         Column(
                           children: <Widget>[

                             SizedBox(height: 20),
                             Row(
                               mainAxisAlignment: MainAxisAlignment
                                   .start,
                               crossAxisAlignment: CrossAxisAlignment
                                   .center,
                               children: <Widget>[
                                 SizedBox(width: 10),

                                 Container(
                                   height: 90,
                                   width: 90,
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
                                     const BorderRadius.all(Radius.circular(60.0)),
                                     child: driverrRequestPackages[index].driver.PhotoURL==null ? Icon(Icons.account_circle,color: Colors.grey,size: 0,) :  Image.network(driverrRequestPackages[index].driver.PhotoURL,fit: BoxFit.cover)
                                     ,

                                   ),
                                 ),
                                 SizedBox(width: 10),
                                 Column(
                                   mainAxisAlignment: MainAxisAlignment
                                       .start,
                                   crossAxisAlignment: CrossAxisAlignment
                                       .start,

                                   children: <Widget>[


                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: <Widget>[
                                         Icon(Icons.date_range,
                                           color: Colors.amber[700], size: 25,),
                                         SizedBox(width: 5),
                                         Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[

                                             Text("Date ",
                                               style: TextStyle(
                                                 color: AppTheme.grey,
                                                 fontSize: 12,
                                               ),
                                             ),
                                             Text(
                                               '${driverrRequestPackages[index].driverRequest.Created.split("T")[0]
                                               }',
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
                                         Icon(Icons.access_time,
                                           color: Colors.amber[700], size: 25,),
                                         SizedBox(width: 5),
                                         Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[

                                             Text("Time ",
                                               style: TextStyle(
                                                 color: AppTheme.grey,
                                                 fontSize: 12,
                                               ),
                                             ),
                                             Text(
                                               '${driverrRequestPackages[index].driverRequest.Created.split("T")[1].substring(0,5)
                                                   }',
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



                                   ],),

                                 SizedBox(width: 10),

                                 Column(

                                   mainAxisAlignment: MainAxisAlignment
                                       .start,
                                   crossAxisAlignment: CrossAxisAlignment
                                       .start,
                                   children: <Widget>[



                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: <Widget>[
                                         Icon(Icons.account_circle,
                                           color: Colors.amber[700], size: 25,),
                                         SizedBox(width: 5),
                                         Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[

                                             Text("Driver ",
                                               style: TextStyle(
                                                 color: AppTheme.grey,
                                                 fontSize: 12,
                                               ),
                                             ),
                                             Text(
                                               '${driverrRequestPackages[index].driver.FirstName}  ${driverrRequestPackages[index].driver.LastName}',
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
                                         Icon(Icons.monetization_on,
                                           color: Colors.amber[700], size: 25,),
                                         SizedBox(width: 5),
                                         Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[

                                             Text("Price ",
                                               style: TextStyle(
                                                 color: AppTheme.grey,
                                                 fontSize: 12,
                                               ),
                                             ),
                                             Text(
                                               '${driverrRequestPackages[index].driverRequest
                                                   .Price}',
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
                             SizedBox(height: 20),
                           ],
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: <Widget>[

                             Align(
                               alignment: Alignment.bottomCenter,
                               child: FlatButton(
                                 onPressed: () {
                                 //  Navigator.of(context).pop();

                                   viewDriver(driverrRequestPackages[index].driverRequest.DriverID);

                                 },
                                 child: Text("Profile"),
                               ),
                             ),

                             Align(
                               alignment: Alignment.bottomRight,
                               child: FlatButton(
                                 onPressed: () {
                                   // Navigator.of(context).pop();

                                   addOnGoingJobFromJobOfferURL(driverrRequestPackages[index].driverRequest.DriverRequestID);

                                 },

                                 child: Text("Assign Job"),
                               ),
                             ),
                           ],

                         ),
                       ],
                     );
                   }

               ),
             ):
             Padding(
               padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),
               child: jobOffers != null ? ListView.builder(
                   controller: list_sc,
                   itemCount: jobOffers.length,
                   itemBuilder: (BuildContext context, int index) {
                     return Padding(
                       padding: EdgeInsets.all(8),

                       child: Column(
                         children: <Widget>[
                           Container(
                             decoration: BoxDecoration(
                                 color: Colors.grey[100],
                                 shape: BoxShape.rectangle,
                                 borderRadius: new BorderRadius.only(
                                   topLeft: const Radius.circular(10.0),
                                   topRight: const Radius.circular(10.0),
                                   bottomLeft: const Radius.circular(10.0),
                                   bottomRight: const Radius.circular(10.0),
                                 ),
                                 boxShadow: [BoxShadow(
                                   color: Color.fromRGBO(0, 0, 0, 0.15),
                                   blurRadius: 8.0,
                                 )
                                 ]
                             ),
                             key: ValueKey(jobOffers[index]),
                             child:  Stack(
                               children: <Widget>[

                                 Column(
                                   children: <Widget>[

                                     SizedBox(height: 20,),
                                     Text(
                                       '${jobOffers[index].jobOfferTrader.JobOfferType}',
                                       style: TextStyle(
                                         fontWeight: FontWeight.w300,
                                         color: AppTheme.grey,
                                         fontSize: 22,
                                       ),
                                     ),
                                     SizedBox(height: 20,),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment
                                           .start,
                                       crossAxisAlignment: CrossAxisAlignment
                                           .start,
                                       children: <Widget>[
                                         SizedBox(width: 20),
                                         Column(
                                           mainAxisAlignment: MainAxisAlignment
                                               .start,
                                           crossAxisAlignment: CrossAxisAlignment
                                               .start,

                                           children: <Widget>[




                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[
                                                 Icon(Icons.monetization_on,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Price",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.Price}',
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
                                                 Icon(Icons.timer,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Weight",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.CargoWeight}',
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
                                                 Icon(Icons.assessment,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Trip Type",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.TripType}',
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
                                                 Icon(Icons.av_timer,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Accepted Delay",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.AcceptedDelay}',
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
                                                 Icon(Icons.location_on,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Loading Place",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Container(
                                                       width: 110,
                                                       child: Text(
                                                         '${jobOffers[index].jobOfferTrader.LoadingPlace}',
                                                         maxLines: 4,
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


                                           ],),

                                         SizedBox(width: 10),

                                         Column(

                                           mainAxisAlignment: MainAxisAlignment
                                               .start,
                                           crossAxisAlignment: CrossAxisAlignment
                                               .start,
                                           children: <Widget>[


                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[
                                                 Icon(Icons.credit_card,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Entry / Exit",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     jobOffers[index].jobOfferTrader.EntryExit==0?
                                                     Text("Not Required",
                                                       style: TextStyle(
                                                         fontWeight: FontWeight.w600,
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ):
                                                     Text("Required",
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
                                                 Icon(Icons.access_time,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Loading Time",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.LoadingTime}',
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
                                                 Icon(Icons.markunread_mailbox,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Cargo Type",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.CargoType}',
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
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Loading Date",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Text(
                                                       '${jobOffers[index].jobOfferTrader.LoadingDate}',
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
                                                 Icon(Icons.location_on,
                                                   color: Colors.amber[700], size: 25,),
                                                 SizedBox(width: 5),
                                                 Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Text("Unloading Place",
                                                       style: TextStyle(
                                                         color: AppTheme.grey,
                                                         fontSize: 12,
                                                       ),
                                                     ),
                                                     Container(
                                                       width: 110,
                                                       child: Text(
                                                         '${jobOffers[index].jobOfferTrader.UnloadingPlace}',
                                                         maxLines: 4,
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
                                     SizedBox(height: 20,),


                                   ],
                                 ),
                                 Positioned(
                                   right: -5,
                                   top: -5,
                                   child: InkWell(
                                     // When the user taps the button, show a snackbar.
                                     onTap: () {
                                       //     pr.show();
                                       deleteRequest(jobOffers[index].jobOfferTrader.JobOfferID);
                                     },
                                     child: Container(
                                       padding: EdgeInsets.all(12.0),
                                       child: Column(
                                         children: <Widget>[

                                           Icon(Icons.cancel,
                                             color: Colors.redAccent, size: 30,),
                                            Text("Delete",style: TextStyle(color: Colors.redAccent),),
                                         ],
                                       ),
                                     ),
                                   ),
                                 ),
                                 Positioned(
                                   right: 0,
                                   bottom: -5,
                                   child: InkWell(
                                     // When the user taps the button, show a snackbar.
                                     onTap: () {
                                     //  jobOffermore(index);
                                       //     pr.show();
                                       showDriverRequest(jobOffers[index].jobOfferTrader.JobOfferID);

                                       //   deleteRequest(jobRequests[index].JobRequestID);
                                     },
                                     child: Container(
                                       padding: EdgeInsets.all(12.0),
                                       child: Column(
                                         children: <Widget>[
                                           jobOffers[index].jobOfferTrader.NumberOfDriverRequests>0?
                                           Badge(
                                             badgeColor:Colors.blue[900],
                                             shape: BadgeShape.circle,
                                             borderRadius: 90,
                                             toAnimate: false,
                                             badgeContent: Padding(
                                                 padding: EdgeInsets.all(3.0),
                                                 child: Text('${jobOffers[index].jobOfferTrader.NumberOfDriverRequests}',style: TextStyle(color: Colors.white),)),
                                             child: Icon(Icons.more_horiz,
                                               color: Colors.black, size: 30,),
                                           ):
                                           SizedBox(),

                                         ],
                                       ),
                                     ),
                                   ),
                                 ),

                               ],
                             ),

                           ),

                           index==jobOffers.length-1?
                           SizedBox(height: 70.0,):
                           SizedBox(height: 0.0,),
                         ],
                       ),
                     );
                   },


               ) : SizedBox(height: 1.0,),

             ):
             jobRequestsloaded?
             Container(
                 alignment: Alignment.center,
                 child: Text("No Job Offers found",style: TextStyle(color:Colors.amber[700]),)
             ):
             //jobOfferloaded
             Container(
                 alignment: Alignment.center,
                 child:  Text("Loading Offers",style: TextStyle(color:Colors.amber[700]),)
             ):tab_postion==3?
                 onGoingJobloaded?
                     ongoingJob!=null?
                 Container(
                   alignment: Alignment.center,
                   child: Column(

                     crossAxisAlignment: CrossAxisAlignment.center,
                     mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[


                       Row(
                         mainAxisAlignment: MainAxisAlignment
                             .center,
                         crossAxisAlignment: CrossAxisAlignment
                             .center,
                         children: <Widget>[
                           Column(
                             mainAxisAlignment: MainAxisAlignment
                                 .start,
                             crossAxisAlignment: CrossAxisAlignment
                                 .start,

                             children: <Widget>[


                               SizedBox(height: 5),

                               Text("Trip Type: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),

                               Text("Cargo Type: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text("Cargo Weight: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Loading Place: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Unloading Place: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Loading Date: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Loading Time: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Entry Exit: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Accepted Delay: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Job Offer Type: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),
                               Text("Price: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),
                               SizedBox(height: 5),
                               Text("Completed by Driver: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),
                               SizedBox(height: 5),
                               Text("Completed by Trader: ",
                                 style: TextStyle(
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                             ],),

                           SizedBox(width: 10),

                           Column(

                             mainAxisAlignment: MainAxisAlignment
                                 .start,
                             crossAxisAlignment: CrossAxisAlignment
                                 .start,
                             children: <Widget>[



                               SizedBox(height: 5),

                               Text('${ongoingJob.TripType}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),

                               Text('${ongoingJob
                                   .CargoType}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .CargoWeight}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),



                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingPlace}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .UnloadingPlace}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingDate}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingTime}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),

                               ongoingJob
                                   .EntryExit==1?
                               Text('Required',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ):  Text('Not Required',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .AcceptedDelay} Hours',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .JobOfferType}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .Price}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w600,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               ongoingJob.CompletedByDriver==0?
                               Icon(Icons.close,
                                 color: Colors.red[500], size: 20,):
                               Icon(Icons.done,
                                 color: Colors.green[500], size: 20,),

                               SizedBox(height: 5),

                               ongoingJob.CompletedByTrader==0?
                               Icon(Icons.close,
                                 color: Colors.red[500], size: 20,):
                               Icon(Icons.done,
                                 color: Colors.green[500], size: 20,)




                             ],
                           ),
                         ],
                       ),

                        SizedBox(height: 50),
                        SizedBox(
                          width:200,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),

                            ),

                            color: primaryDark,
                            onPressed: () async {
                              //   await loginUser();
                              viewDriver(ongoingJob.DriverID);
                            },
                            child: Text( "View Driver",style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        SizedBox(height: 50),
                        Visibility(
                          visible: ongoingJob.CompletedByDriver==1,
                          child: SizedBox(
                            width:200,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),

                              ),

                              color: primaryDark,
                              onPressed: () async {
                                //   await loginUser();
                                completeJob();
                              },
                              child: Text( "Approve Job",style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                     ],
                   ),
                 ):
             Container(
                 alignment: Alignment.center,
                 child: Text("No On-Going Found",style: TextStyle(color: Colors.deepPurpleAccent[200]),),
             ):Container(
                   alignment: Alignment.center,
                   child: Text("Loading On-Going ",style: TextStyle(color: Colors.deepPurpleAccent[200]),),
                 ):

             compleatedJobs!=null?
             Padding(
               padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),
               child: compleatedJobs != null ? ListView.builder(
                   controller: list_sc,
                   itemCount: compleatedJobs.length,

                   itemBuilder: (BuildContext context, int index) {
                     return Padding(
                       padding: EdgeInsets.all(8),

                       child: Container(
                         decoration: BoxDecoration(
                             color: Colors.grey[100],
                             shape: BoxShape.rectangle,
                             borderRadius: new BorderRadius.only(
                               topLeft: const Radius.circular(10.0),
                               topRight: const Radius.circular(10.0),
                               bottomLeft: const Radius.circular(10.0),
                               bottomRight: const Radius.circular(10.0),
                             ),
                             boxShadow: [BoxShadow(
                               color: Color.fromRGBO(0, 0, 0, 0.15),
                               blurRadius: 8.0,
                             )
                             ]
                         ),
                         key: ValueKey(compleatedJobs[index]),
                         child:

                             Column(
                               mainAxisAlignment: MainAxisAlignment
                                   .start,
                               crossAxisAlignment: CrossAxisAlignment
                                   .start,
                               children: <Widget>[
                                 SizedBox(height: 20),
                                 Row(
                                   children: <Widget>[
                                     SizedBox(width: 20),
                                     Icon(Icons.done,
                                       color: Colors.green[600], size: 25,),
                                     SizedBox(width: 10),
                                     Container(
                                       width: screenWidth(context)*0.8,
                                       child: Text(
                                         'Cargo was Deliverred from ${compleatedJobs[index].completedJob
                                             .LoadingPlace} to ${compleatedJobs[index].completedJob
                                             .UnloadingPlace}',
                                         maxLines: 3,
                                         style: TextStyle(
                                           fontWeight: FontWeight.w300,
                                           color: AppTheme.grey,
                                           fontSize: 22,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                                 SizedBox(height: 20),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment
                                       .start,
                                   crossAxisAlignment: CrossAxisAlignment
                                       .start,
                                   children: <Widget>[
                                     SizedBox(width: 30),
                                     Column(
                                       mainAxisAlignment: MainAxisAlignment
                                           .start,
                                       crossAxisAlignment: CrossAxisAlignment
                                           .start,

                                       children: <Widget>[



                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                             Icon(Icons.format_align_justify,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Job Number ",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .JobNumber}',
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
                                             Icon(Icons.assessment,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Trip Type",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .TripType}',
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
                                             Icon(Icons.assessment,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Accepted Delay",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .AcceptedDelay}',
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
                                             Icon(Icons.credit_card,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Entry / Exit",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 compleatedJobs[index].completedJob.EntryExit==0?
                                                 Text("Not Required",
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w600,
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ):
                                                 Text("Required",
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
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Completed On",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob.Created.split("T")[0]}',
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


                                       ],),

                                     SizedBox(width: 30),

                                     Column(

                                       mainAxisAlignment: MainAxisAlignment
                                           .start,
                                       crossAxisAlignment: CrossAxisAlignment
                                           .start,
                                       children: <Widget>[

                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                             Icon(Icons.date_range,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Loading Date",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .LoadingDate}',
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
                                             Icon(Icons.access_time,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Loading Time",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .LoadingTime}',
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
                                             Icon(Icons.markunread_mailbox,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Cargo Type",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .CargoType}',
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
                                             Icon(Icons.timer,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Cargo Weight",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob
                                                       .CargoWeight}',
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
                                             Icon(Icons.access_time,
                                               color: Colors.green[600], size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Completed at",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${compleatedJobs[index].completedJob.Created.split("T")[1].substring(0,5)}',
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
                                 SizedBox(height: 20),
                                 compleatedJobs[index].driverReview!=null?
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[

                                     SizedBox(width: 30),
                                     Column(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: <Widget>[

                                         Text(" Rating",
                                           style: TextStyle(
                                             color: AppTheme.grey,
                                             fontSize: 12,
                                           ),
                                         ),
                                     //compleatedJobs[index].driverReview.Rating.toString())/20
                                         IgnorePointer(
                                           ignoring: true,
                                           child: RatingBar(
                                             onRatingChanged: (e){

                                             },

                                             initialRating: double.parse(compleatedJobs[index].driverReview.Rating.toString())/20,
                                             filledIcon: Icons.star,
                                             emptyIcon: Icons.star_border,
                                             isHalfAllowed: false,
                                              filledColor: Colors.green,
                                             emptyColor: Colors.grey,
                                             halfFilledColor: Colors.amberAccent,
                                             size: 25,
                                           ),
                                         ),

                                       ],
                                     ),
                                   ],
                                 ):
                                 Align(
                                   alignment: Alignment.bottomRight,
                                   child: FlatButton(
                                     onPressed: () {
                                       Dialog dialog= Dialog(
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(60),
                                         ),
                                         elevation: 0.0,
                                         backgroundColor: Colors.transparent,
                                         child: rateDialogue(context,compleatedJobs[index].completedJob.CompletedJobID),
                                       );

                                       showDialog(context: context, builder: (BuildContext context) => dialog);
                                     },
                                     child: Text("Rate"),
                                   ),
                                 ),

                                 SizedBox(height: 10),
                                 compleatedJobs[index].driverReview!=null?
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[
                                     SizedBox(width: 30),
                                     Icon(Icons.rate_review,
                                       color: Colors.green[600], size: 25,),
                                     SizedBox(width: 5),
                                     Column(
                                       mainAxisAlignment: MainAxisAlignment.start,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: <Widget>[

                                         Text("Review",
                                           style: TextStyle(
                                             color: AppTheme.grey,
                                             fontSize: 12,
                                           ),
                                         ),
                                         Text(

                                           '${compleatedJobs[index].driverReview
                                               .Review}',
                                           style: TextStyle(
                                             fontWeight: FontWeight.w600,
                                             color: AppTheme.grey,

                                             fontSize: 12,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ):SizedBox(),

                               ],
                             ),
                       ),
                     );
                   }

               ) : SizedBox(height: 1.0,),

             ):
             tab_postion==4?
             CompletedJobloaded?
             Container(
                 alignment: Alignment.center,
                 child: Text("No Compleated found",style: TextStyle(color:Colors.green[600]),)
             ):
             Container(
               alignment: Alignment.center,
               child: Text("Loading Compleated Jobs",style: TextStyle(color: Colors.green[600]),),
             ):SizedBox(),


             // Job Offers

           ],

         )
     );
   }
double _rating;

  FocusNode focusNodeloadingPlace,focusNodeunloadingPlace,focusNodePrice;

  final GlobalKey<FormState> _formJobRequestKey = GlobalKey<FormState>();
  _displayJobRequestDialog(BuildContext context,int id) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: requestdialogContent(context,id),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }
  bool checkenteryrxit = false;
  String cargotype,cargoweight,accepteddelay,loadingdate,loadingtime;
  requestdialogContent(BuildContext context,int id) {
    return SingleChildScrollView(
      child: Form(
        key: _formJobRequestKey,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top:  16.0,
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
                      "Send Job Request",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 26.0),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.shopping_basket),
                          Container(
                            width: screenWidth(context)*0.5,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.number,
                              initialValue: cargotype,
                              onChanged: (String value) {
                                if(!value.isEmpty)
                                  cargotype = value;
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
                    Row(
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
                                  initialValue: cargoweight,
                                  onChanged: (String value) {
                                    if(!value.isEmpty)
                                      cargoweight = value;
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
                                  initialValue: accepteddelay,
                                  onChanged: (String value) {
                                    if(!value.isEmpty)
                                      accepteddelay = value;
                                  },
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
                      ],
                    ),
                    // SizedBox(height: 16.0),

                    Container(
                      height: 100,
                      width: screenWidth(context)*0.7,
                      child: Column(
                        children: <Widget>[

                          Text("Loading Date and Time"),
                          SizedBox(height: 10,),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              onDateTimeChanged: (data){

                                loadingdate=data.toIso8601String().split("T")[0];
                            //    loadingdate="${data.day}-${data.month}-${data.year}";
                                loadingtime=data.toIso8601String().split("T")[1];
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
                          value: checkenteryrxit,
                          onChanged: (bool value) {
                            checkenteryrxit = value;
                              Navigator.of(context).pop();
                              _displayJobRequestDialog(context,id);


                          },
                        ),
                        Text("Entery / Exit ",),
                      ],
                    ),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              cargotype="";
                              cargoweight="";
                              loadingdate="";
                              accepteddelay="";
                              loadingtime="";
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              //  pr.show();

                              final FormState form = _formJobRequestKey.currentState;
                              form.save();
                              uploadjobRequest(id);
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

          ],
        ),
      ),
    );


  }

  Future<void> deleteRequest(int JobOfferID) async {
    print("Deleting Offer $JobOfferID");
    showLoadingDialogue("Deleting Offer");
    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deleteTraderJobofferURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);


    //   request.write('{"Token": "'+DriverProfile.getUserToken()+'","PermitLicenceID": "$permitLicenceID"}');
    request.write('{"JobOfferID": "$JobOfferID"}');

    final response = await request.close();


    response.transform(convert.utf8.decoder).listen((contents) async {
      print(contents);

      Map<String, dynamic> updateMap = convert.jsonDecode(contents) as Map<String, dynamic>;

      setState(() {
        hideLoadingDialogue();
        loadjobOffers();

      });


    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  void addjobRequest(int id) {
    _displayJobRequestDialog(context,id);
  }


  Future<void> uploadjobRequest(int id) async {
    print("sending Job Request ${id}");

    final client = HttpClient();
    try{
    final request = await client.postUrl(Uri.parse("https://naqel-server.azurewebsites.net/traders/addTraderRequest"));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    int ee;
    checkenteryrxit?ee=1:ee=0;

   //  String cargotype,cargoweight,accepteddelay,loadingdate,loadingtime;

    print('{'
        '"JobRequestID":"${id}",'
        '"CargoType":"${cargotype}",'
        '"CargoWeight":"${cargoweight}",'
        '"LoadingDate":"${loadingdate}",'
        '"LoadingTime":"${loadingtime}",'
        '"EntryExit":"${ee}",'
        '"AcceptedDelay":"${accepteddelay}"'
        '}');

    request.write('{'
        '"JobRequestID":"${id}",'
        '"CargoType":"${cargotype}",'
        '"CargoWeight":"${cargoweight}",'
        '"LoadingDate":"'+loadingdate+'",'
        '"LoadingTime":"23:21",'
        '"EntryExit":"${ee}",'
        '"AcceptedDelay":"${accepteddelay}"'
        '}');


    final response = await request.close();


    response.transform(convert.utf8.decoder).listen((contents) async {
      print(contents);


      setState(() {
        cargotype="";
        cargoweight="";
        loadingdate="";
        accepteddelay="";
        loadingtime="";
       // loadjobRequests();

      });


    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  Future<void> completeJob() async {
    print("Approve Job");

    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.traderapproveJobJobURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);



      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        Map<String, dynamic> updateMap = convert.jsonDecode(contents) as Map<String, dynamic>;

        setState(() async {

          isonJob=false;
          ongoingJob=null;
          DataStream.ongoingJob=null;
          loadonGoingJob();
        });


      });
    }catch(e){

      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }

  }

  bool driverrRequestPackagesloaded = false;

  Future<void> showDriverRequest(int id) async {
    print("Loading DriverRequest $id");

    showLoadingDialogue("Loading Driver Requests");
    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getDriverRequestPackagesURL()+"?JobOfferID=$id ", headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);

 
        if(jobRequestsMap["DriverRequestPackages"]!= null) {

          DataStream.driverrRequestPackages =DataStream.parseDriverRequestPackages(jobRequestsMap["DriverRequestPackages"]);
          // print(jobRequestsMap["DriverRequestPackages"]);
          driverrRequestPackages = DataStream.driverrRequestPackages;

        }
        hideLoadingDialogue();

        driverrRequestPackagesloaded=true;
        setState(() {
        });

      }



    }catch(e){
      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }



  }

  _displayJobOfferDialog(BuildContext context) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: offerdialogContent(context),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }
  String dropdownValue = 'One Way';

  List <String> spinnerItems = [
    'One Way',
    'Two Way',
  ] ;
  LatLng loadinglatlon,unloadinglatlon;

  final myController = TextEditingController();

  offerdialogContent(BuildContext context) {
    return SingleChildScrollView(
      child:  Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top:  16.0,
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
                    "Add Job Offer",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20.0),


                  Container(
                    margin: EdgeInsets.only(bottom: 18.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.file_upload),
                        Container(
                          width: screenWidth(context)*0.5,
                          child: TextFormField(
                            cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                            keyboardType: TextInputType.text,
                            initialValue: LoadingPlace,
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
                          width: screenWidth(context)*0.5,
                          child: TextFormField(
                            cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                            keyboardType: TextInputType.text,
                            initialValue: UnloadingPlace,
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
                                controller: myController,
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
                                initialValue: CargoType,
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
                    ],
                  ),

                  Row(
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
                                initialValue: CargoWeight,
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
                                initialValue: AcceptedDelay,
                                onChanged: (String value) {
                                  if(!value.isEmpty)
                                    AcceptedDelay = value;
                                },
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
                    ],
                  ),
                  // SizedBox(height: 16.0),

                  Container(
                    height: 100,
                    width: screenWidth(context)*0.7,
                    child: Column(
                      children: <Widget>[

                        Text("Loading Date and Time"),
                        SizedBox(height: 10,),
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
                          Navigator.of(context).pop();
                          _displayJobOfferDialog(context);


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
                            Navigator.of(context).pop();
                            dropdownValue = data;
                            TripType=dropdownValue;
                            _displayJobOfferDialog(context);


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



                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            TripType= CargoType= CargoWeight= LoadingPlace= UnloadingPlace= LoadingDate= LoadingTime= Price= AcceptedDelay= JobOfferType="";
                            myController.text="";
                            Navigator.of(context).pop(); // To close the dialog
                          },
                          child: Text("Dismiss"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            //  pr.show();

                            Price = myController.text;


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

        ],
      ),
    );


  }


  Future<void> addLoadLocation() async {

    LocationResult result = await showLocationPicker(
      context,
      googleAPIKey,
      initialCenter: userPosition,
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,

    );
    print("result = $result");
    if(result!=null){
      LoadingPlace = result.address;
      LoadingLat=result.latLng.latitude.toString();
      LoadingLng=result.latLng.longitude.toString();

      Navigator.of(context).pop();

      _displayJobOfferDialog(context);
    }
  }

  Future<void> addUnloadLocation() async {

    LocationResult result = await showLocationPicker(
      context,
      googleAPIKey,
      initialCenter: userPosition,
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,

    );
    print("result = $result");
    if(result!=null){
      UnloadingPlace = result.address;
      UnloadingLat=result.latLng.latitude.toString();
      UnloadingLng=result.latLng.longitude.toString();

      Navigator.of(context).pop();

      _displayJobOfferDialog(context);
    }
  }

  DateTime temp ;
  bool EntryExitbol=false;
  String TripType, CargoType, CargoWeight, LoadingPlace, UnloadingPlace, LoadingDate, LoadingTime, Price, AcceptedDelay, JobOfferType;

  String LoadingLat;
  String LoadingLng;
  String UnloadingLat;
  String UnloadingLng;

  Future<void> addjobOffer() async {

    showLoadingDialogue("Adding Job Offer");
    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.addJobOfferURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


//DATA: { TripType, CargoType, CargoWeight, LoadingPlace, UnloadingPlace, LoadingDate, LoadingTime, EntryExit,
//Price, AcceptedDelay, JobOfferType }

      JobOfferType=   "Fixed-Price";
      TripType="Two Way";
      CargoType = "Bookssss";
      AcceptedDelay = "2";
      print(
          '{"TripType": "$TripType","CargoType": "$CargoType","CargoWeight": "$CargoWeight",'
              '"LoadingPlace": "$LoadingPlace","UnloadingPlace": "$UnloadingPlace","LoadingDate": "'+LoadingDate+'",'
              '"LoadingTime": "'+LoadingTime+'","EntryExit": "0","Price": "$Price",'
              '"AcceptedDelay": "$AcceptedDelay","JobOfferType": "$JobOfferType"'
              ',"LoadingLat": "$LoadingLat","LoadingLng": "$LoadingLng"'
              ',"UnloadingLat": "$UnloadingLat","UnloadingLng": "$UnloadingLng"}');

      /*
      if(EntryExitbol) {
        request.write(
            '{"TripType": "$TripType","CargoType": "$CargoType","CargoWeight": "$CargoWeight",'
                '"LoadingPlace": "$LoadingPlace","UnloadingPlace": "$UnloadingPlace","LoadingDate": "$LoadingDate",'
                '"LoadingTime": "$LoadingTime","EntryExit": "1","Price": "$Price",'
                '"AcceptedDelay": "$AcceptedDelay","JobOfferType": "$JobOfferType"'
                ',"LoadingLat": "$LoadingLat","LoadingLng": "$LoadingLng"'
                ',"UnloadingLat": "$UnloadingLat","UnloadingLng": "$UnloadingLng"}');
      }else{
        request.write(
            '{"TripType": "$TripType","CargoType": "$CargoType","CargoWeight": "$CargoWeight",'
                '"LoadingPlace": "$LoadingPlace","UnloadingPlace": "$UnloadingPlace","LoadingDate": "$LoadingDate",'
                '"LoadingTime": "$LoadingTime","EntryExit": "0","Price": "$Price",'
                '"AcceptedDelay": "$AcceptedDelay","JobOfferType": "$JobOfferType"'
                ',"LoadingLat": "$LoadingLat","LoadingLng": "$LoadingLng"'
                ',"UnloadingLat": "$UnloadingLat","UnloadingLng": "$UnloadingLng"}');
      }
      */


      int ee;
      checkenteryrxit?ee=1:ee=0;

      request.write(
          '{"TripType": "$TripType","CargoType": "$CargoType","CargoWeight": "$CargoWeight",'
              '"LoadingPlace": "$LoadingPlace","UnloadingPlace": "$UnloadingPlace","LoadingDate": "'+LoadingDate+'",'
              '"LoadingTime": "'+LoadingTime+'","EntryExit": "$ee","Price": "$Price",'
              '"AcceptedDelay": "$AcceptedDelay","JobOfferType": "$JobOfferType"'
              ',"LoadingLat": "$LoadingLat","LoadingLng": "$LoadingLng"'
              ',"UnloadingLat": "$UnloadingLat","UnloadingLng": "$UnloadingLng"}');

      final response = await request.close();



      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        hideLoadingDialogue();
        setState(() {
          TripType= CargoType= CargoWeight= LoadingPlace= UnloadingPlace= LoadingDate= LoadingTime= Price= AcceptedDelay= JobOfferType="";
          myController.text="";

           LoadingLat ="";
           LoadingLng="";
           UnloadingLat="";
           UnloadingLng="";
          loadjobRequests();
        });

      });
    }catch(e){

      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }

  Future<void> addOnGoingJobFromJobRequest(int id) async {
    print("addOnGoingJobFromJobRequest $id");
    showLoadingDialogue("Assigning Job");
    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.addOnGoingJobFromJobRequestURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      request.write('{"TraderRequestID": "$id"}');

      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        hideLoadingDialogue();
        setState(() {
          loadjobRequests();
        });

      });
    }catch(e){

      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }
  Future<void> addOnGoingJobFromJobOfferURL(int id) async {
    print("addOnGoingJobFromJobOfferURL $id");

    showLoadingDialogue("Assigning Job");



    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.addOnGoingJobFromJobOfferURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      request.write('{"DriverRequestID": "$id"}');

      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        hideLoadingDialogue();
        setState(() {
          driverrRequestPackagesloaded=false;
          loadjobOffers();
        });

      });
    }catch(e){

      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }



  void jobOffermore(int index) {
    _displayJoboffermoreDialog(context,index);

  }
  _displayJoboffermoreDialog(BuildContext context,int index) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: joboffermoredialogContent(context,index),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }

  String review;
  rateDialogue(BuildContext context,int id) {
    return SingleChildScrollView(
      child: Form(
        key: _formJobRequestKey,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top:  16.0,
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
                      "Rate Driver",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),

                    RatingBar(
                      onRatingChanged: (rating) => setState(() =>  _rating = rating*20),
                      initialRating: 0,
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      isHalfAllowed: false,
                      filledColor: Colors.green,
                      emptyColor: Colors.grey,
                      halfFilledColor: Colors.amberAccent,
                      size: 45,
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.rate_review),
                          Container(
                            width: screenWidth(context)*0.6,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.multiline,
                              initialValue: cargotype,
                              maxLength: 200,
                              maxLines: 4,
                              onChanged: (String value) {
                                if(!value.isEmpty)
                                  review = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Review';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Review",

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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Dismiss"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              final FormState form = _formJobRequestKey.currentState;
                              form.save();
                              addReview(id);
                              Navigator.of(context).pop();

                            },
                            child: Text("Submit"),
                          ),
                        ),
                      ],

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
  joboffermoredialogContent(BuildContext context,int index) {
    return SingleChildScrollView(
      child: Form(
        key: _formJobRequestKey,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top:  16.0,
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
                      "Job Offer",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 26.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start,
                      crossAxisAlignment: CrossAxisAlignment
                          .start,
                      children: <Widget>[
                         Column(
                          mainAxisAlignment: MainAxisAlignment
                              .start,
                          crossAxisAlignment: CrossAxisAlignment
                              .start,

                          children: <Widget>[


                            SizedBox(height: 5),

                            Text("Trip Type: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text("Cargo Type: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text("Cargo Weight: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Loading Place: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Unloading Place: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Loading Date: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Loading Time: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Entry Exit: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Accepted Delay: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Job Offer Type: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),
                            Text("Price: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                          ],),

                        SizedBox(width: 10),

                        Column(

                          mainAxisAlignment: MainAxisAlignment
                              .start,
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: <Widget>[



                            SizedBox(height: 5),

                            Text('${jobOffers[index].jobOfferTrader.TripType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text('${jobOffers[index].jobOfferTrader
                                .CargoType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .CargoWeight}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),



                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .LoadingPlace}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .UnloadingPlace}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .LoadingDate}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .LoadingTime}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),

                            jobOffers[index].jobOfferTrader
                                .EntryExit==1?
                            Text('Required',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ):  Text('Not Required',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .AcceptedDelay} Hours',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .JobOfferType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOfferTrader
                                .Price}',
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
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FlatButton(
                            onPressed: () {

                              Navigator.of(context).pop(); // To close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                            },
                            child: Text("Trader "),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                            },
                            child: Text("Map"),
                          ),
                        ),
                      ],

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

  Future<void> addReview(int id) async {
    print("add Review $id");

    showLoadingDialogue("Adding Review");

    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.addDriverReviewURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      request.write('{"CompletedJobID": "$id","Rating": "$_rating","Review": "$review"}');

      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

        hideLoadingDialogue();
        setState(() {
          CompletedJobloaded=false;
          loadCompletedJob();
        });

      });
    }catch(e){

      hideLoadingDialogue();
      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }

  }

  Future<void> viewDriver(int id) async {


    showLoadingDialogue("Loading Driver Profile");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };

    try{
      final response = await http.get(URLs.getDriverProfileURL()+"?DriverID=${id}", headers:requestHeaders);

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> map = convert.jsonDecode(response.body);



        hideLoadingDialogue();

        Dialog dialog = Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: driverProfiledialogContent(context,new DriverProfile.fromJson(map["Driver"])),
        );

        showDialog(context: context, builder: (BuildContext context) => dialog);



      }


    }catch(e){

      print(e.toString());
      hideLoadingDialogue();

    }








  }


  driverProfiledialogContent(BuildContext context,DriverProfile driver) {
    return SingleChildScrollView(
      child:  Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 100.0+ 16.0,
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
                    "${driver.FirstName} ${driver.LastName}",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.0),

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
                                    '${driver.Nationality}',
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
                                    '${driver.DateOfBirth}',
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
                                  Container(
                                    width: 100,
                                    child: Text(
                                      '${driver.Email}',
                                      maxLines: 3,
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
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[


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
                                    '${driver.Gender}',
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
                                    '${driver.PhoneNumber}',
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
                                    width: 100,
                                    child: Text(
                                      '${driver.Address}',
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

                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),

                  // SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                          },
                          child: Text("Dismiss"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            //Navigator.of(context).pop();

                          },
                          child: Text("Documents"),
                        ),
                      ),

                    ],

                  ),
                ],
              ),
            ),
          ),

          Positioned(

            left: (screenWidth(context)/3)-68,

            child: new Stack(
              alignment:new Alignment(1, 1),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,0),
                  child:  Container(
                    height: 200,
                    width: 200,
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
                        child:  Image.network(driver.PhotoURL,fit: BoxFit.cover)


                    ),
                  ),
                ),


              ],
            ),

          ),
        ],
      ),

    );


  }





}

