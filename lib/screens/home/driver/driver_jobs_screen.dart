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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:naqelapp/models/commons/CompletedJob.dart';
import 'package:naqelapp/models/commons/Objections.dart';
import 'package:naqelapp/models/driver/jobs/JobOfferPosts.dart';
import 'package:naqelapp/models/driver/jobs/JobRequests.dart';
import 'package:naqelapp/models/commons/OngoingJob.dart';
import 'package:naqelapp/models/driver/jobs/TraderRequestPackages.dart';
import 'package:naqelapp/models/trader/TraderProfile.dart';
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
import 'package:http/http.dart' as http;



class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key key}) : super(key: key);

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}
class _DriverHomePageState extends State<DriverHomePage>  {
  ScrollController _controllerddd = ScrollController();

   Completer<GoogleMapController> _controller = Completer();
  static LatLng latLng =LatLng(0, 0,);
   PanelController _pc = new PanelController();
  List<JobRequests>  jobRequests;
  List<TraderRequestPackages>  traderRequestPackages;
  List<JobOfferPosts>  jobOffers;
  List<CompletedJobPackages>  compleatedJobs;

  OngoingJob ongoingJob;


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
  String googleAPIKey = "AIzaSyD_U_2NzdPIL7TWb8ECBHWO1eROR2yrebI";
  final locationDbRef = FirebaseDatabase.instance.reference();


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

    Future.wait([loadjobOffers(), loadjobRequests(), loadonGoingJob(),loadCompletedJob()])
        .catchError((e) {
      print(e);

    });
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
       result.forEach((PointLatLng point){
        polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
       // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates
      );

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }
  int tab_postion=0;
 bool fab_visible = false;

  Dialog loadingdialog;
  @override
  void initState(){
    super.initState();




    _fabHeight = _initFabHeight;

    _focusNodebid = new FocusNode();
    _focusNodebid.addListener(_onOnFocusNodeEvent);

    focusNodeloadingPlace = new FocusNode();
    focusNodeloadingPlace.addListener(_onOnFocusNodeEvent);

    focusNodeWaitingTime = new FocusNode();
    focusNodeWaitingTime.addListener(_onOnFocusNodeEvent);

    focusNodeunloadingPlace = new FocusNode();
    focusNodeunloadingPlace.addListener(_onOnFocusNodeEvent);


    focusNodePrice = new FocusNode();
    focusNodePrice.addListener(_onOnFocusNodeEvent);
   // jobRequests=DriverProfile.getJobRequests();
    getLocation();


    setState(() {});



  }
  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }
  int trader_requests_number=0,job_offer_number=0;
   bool jobRequestsloaded=false;

  Future<void> loadjobRequests() async {
    print("Loading jobRequests");
    showLoadingDialogue("Loading");

    try{

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };
    final response = await http.get(URLs.getJobRequestPackagesURL(), headers:requestHeaders);

    if (response.statusCode == 200) {

      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse);
      Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);

      if(jobRequestsMap["JobRequests"]!= null) {
        DataStream.requests =DataStream.parseRequests(jobRequestsMap["JobRequests"]);
        print(jobRequestsMap["JobRequests"]);
        jobRequests = DataStream.requests;
        trader_requests_number=0;
        for(int i=0;i<=jobRequests.length-1;i++){
          trader_requests_number=trader_requests_number+jobRequests[i].NumberOfTraderRequests;
        }
      }else{
        jobRequests=null;
      }
      print(trader_requests_number.toString());
      jobRequestsloaded=true;

      hideLoadingDialogue();
      setState(() {
      });

    }



  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  
  List<LatLng> Loadingplaces ;
  List<LatLng> Unloadingplaces;
  bool jobOfferloaded=false;

  Future<void> loadjobOffers() async {
    print("Loading jobOffers");
    showLoadingDialogue("Loading");


    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };
    final response = await http.get(URLs.getJobOfferPostsURL(), headers:requestHeaders);

    if (response.statusCode == 200) {

      var jsonResponse = convert.jsonDecode(response.body);

      print(jsonResponse);

      Map<String, dynamic> map = convert.jsonDecode(response.body);


      if(map["JobOfferPosts"]!= null) {
        DataStream.joboffersposts =
            DataStream.parseJobOffer(map["JobOfferPosts"]);
        print(map["JobOfferPosts"]);
        jobOffers = DataStream.joboffersposts;
        final GoogleMapController controller = await _controller.future;
        job_offer_number=0;
        for(int i=0;i<=jobOffers.length-1;i++) {
         job_offer_number++;

     //     Loadingplaces.add(new LatLng(jobOffers[i].jobOffer.LoadingLat, jobOffers[i].jobOffer.LoadingLng));
    //      Unloadingplaces.add(new LatLng(jobOffers[i].jobOffer.UnloadingLat, jobOffers[i].jobOffer.UnloadingLat));


   //       addImageMarker(new LatLng(jobOffers[i].jobOffer.LoadingLat, jobOffers[i].jobOffer.LoadingLng),controller,jobOffers[i].trader.PhotoURL,i+1);

       //   print("addImageMarker"+LatLng(jobOffers[i].jobOffer.LoadingLat, jobOffers[i].jobOffer.LoadingLng).toString());
        }
      }
      hideLoadingDialogue();
      jobOfferloaded=true;
      setState(() {
      });

    }




  }


  bool CompletedJobloaded=false;

  Future<void> loadCompletedJob() async {
    print("Loading CompletedJob");
    showLoadingDialogue("Loading");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };
    final response = await http.get(URLs.getCompletedJobPackagesURL(), headers:requestHeaders);

    if (response.statusCode == 200) {

      var jsonResponse = convert.jsonDecode(response.body);

      print(jsonResponse);

      Map<String, dynamic> map = convert.jsonDecode(response.body);

       if(map["CompletedJobPackages"]!= null) {
         DataStream.compleatedJobspackage =
             DataStream.parseCompletedJobs(map["CompletedJobPackages"]);
         //print(map["CompletedJobPackages"]);
         compleatedJobs = DataStream.compleatedJobspackage;

       }
       hideLoadingDialogue();
       CompletedJobloaded=true;
       setState(() {
       });

    }

  }


  bool onGoingJobloaded=false;

  Future<void> loadonGoingJob() async {
    print("Loading GoingJob");
    showLoadingDialogue("Loading");

    try{

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };
    final response = await http.get(URLs.getOnGoingJobURL(), headers:requestHeaders);

    if (response.statusCode == 200) {

      var jsonResponse = convert.jsonDecode(response.body);

      print(jsonResponse);

      Map<String, dynamic> map = convert.jsonDecode(response.body);

      if(map["OnGoingJob"]!= null) {
        DataStream.ongoingJob =
        new OngoingJob.fromJson(map["OnGoingJob"]);
        //print(map["OnGoingJob"]);
        ongoingJob = DataStream.ongoingJob;

    //    _toggleListening();
     //     setPolylines();
       //   setMapPins();


        setMapPins();
        setPolylines();

      }else{
        ongoingJob=null;
      }
      hideLoadingDialogue();
      onGoingJobloaded=true;
      setState(() {
      });

    }



  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }
  LatLng userPosition;
   Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

   StreamSubscription<Position> _positionStreamSubscription;

  void _toggleListening() async {



    print("Listning Toggled");
      const LocationOptions locationOptions =
      LocationOptions(accuracy: LocationAccuracy.medium);
      final Stream<Position> positionStream =
      Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen(
              (Position position)  async {


                  if(ongoingJob!=null) {
                    print(position);
                  if (ongoingJob.CompletedByDriver == 0) {
                    addToFirebase(position);
                  }
                }
              }
      );

  }
  bool trackuser=false;
  addToFirebase(Position position) async {

    print(position);
    locationDbRef.child('${DataStream.driverProfile.DriverID}').set({
      'latlong': '${position.latitude},${position.longitude}',

    }).then((_) {
      print(userPosition.toString());
    }).catchError((onError) {
      print(onError);
    });


    userPosition = new LatLng(position.latitude, position.longitude);

    final GoogleMapController controller = await _controller.future;

    addImageMarker(userPosition,controller,DataStream.driverProfile.PhotoURL,0);


  }


  Future<void> getLocation() async {

   // print(userPosition.toString());
   //  Map<Permission, PermissionStatus> statuses = await [
   //    Permission.location,
   //  ].request();


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
       print('granted');


        await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position _position) async {
          if (_position != null) {
            userPosition = LatLng(_position.latitude, _position.longitude);

            final GoogleMapController controller = await _controller.future;
            addImageMarker(userPosition, controller ,DataStream.driverProfile.PhotoURL,0);

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
   Marker marker;
   Future<void> addImageMarker(LatLng p,GoogleMapController controller,String photoUrl ,int id) async {


     final File markerImageFile = await DefaultCacheManager().getSingleFile(DataStream.driverProfile.PhotoURL);
   //  final File markerImageFile = await DefaultCacheManager().getSingleFile("");

     final Uint8List markerImageBytes = await markerImageFile.readAsBytes();



     var markerIdVal = "Location$id";
     final MarkerId markerId = MarkerId(markerIdVal);


      marker = Marker(
         icon: await getMarkerIcon( Size(150.0, 150.0),photoUrl),
        markerId: markerId,
        infoWindow:InfoWindow(title: '${ DataStream.driverProfile.FirstName} ${ DataStream.driverProfile.LastName}' ),

        position: LatLng(
         p.latitude ,
         p.longitude ,
       ),

       onTap: () {
         print("Marker Tap");

        },
     );

     setState(() {
       // adding a new marker to map
       markers[markerId] = marker;
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

                    print("Reload");
                   setState(()  {

                     _polylines.clear();
                     polylineCoordinates.clear();
                     polylinePoints =null;
                     polylinePoints = PolylinePoints();


                     onGoingJobloaded=false;
                     jobRequestsloaded=false;
                     jobOfferloaded=false;
                     CompletedJobloaded=false;
                   });

                   showLoadingDialogue("Reloading");
                    Future.wait([loadjobOffers(), loadjobRequests(), loadonGoingJob(),loadCompletedJob()])
                        .catchError((e) {
                          print(e);
                          hideLoadingDialogue();
                    }).then((value){
                      hideLoadingDialogue();
                    });


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
                          traderRequestPackagesloaded=false;
                          _pc.open();
                              if(!jobRequestsloaded) {
                                loadjobRequests();
                              }
                          setState(() {

                          });
                        },
                        child: Column(
                        children: <Widget>[
                          jobRequestsloaded&&trader_requests_number!=0?
                          Badge(
                            badgeColor: tab_postion==1||tab_postion==0?Colors.blue[900]:Colors.grey[700],
                            badgeContent: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(trader_requests_number.toString(),style: TextStyle(color: Colors.white),)),

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

                          ),
                      ),
                          GestureDetector(
                            onTap: (){
                              print("offers clicker");
                              tab_postion=2;
                              if(!jobOfferloaded) {
                                loadjobOffers();
                              }
                              _pc.open();
                              setState(() {

                              });
                            },
                            child: Column(
                              children: <Widget>[

                                jobOfferloaded&&job_offer_number!=0?
                                Badge(
                                  badgeColor: tab_postion==2||tab_postion==0?Colors.amber[900]:Colors.grey[700],
                                  badgeContent:Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text('${jobOffers.length}',style: TextStyle(color: Colors.white),)),
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
                              if(!onGoingJobloaded) {
                                loadonGoingJob();
                              }
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
                               if(!CompletedJobloaded) {
                                loadCompletedJob();
                              }
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
            //  myLocationEnabled: true,
           //   compassEnabled: true,
              tiltGesturesEnabled: false,
            //  markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              onTap: (g){
                trackuser=false;
              },
              initialCameraPosition: initialLocation,
              onMapCreated: (GoogleMapController controller) {
                onMapCreated(controller);
                },
                markers: Set<Marker>.of(markers.values),
            ),



            onPanelOpened: (){
              if(tab_postion==1){
                fab_visible=true;
              }else{
                fab_visible=false;
              }
              fab_icon=Icons.arrow_downward;
              if(tab_postion==0){
                tab_postion=2;
                if(!jobOfferloaded) {
                  loadjobOffers();
                }
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

          Visibility(
            visible: ongoingJob==null?false:true,
            child: Positioned(
              left: 20.0,
              bottom: _fabHeight-15,
              child: FloatingActionButton(
                child: Icon(
                  Icons.call_split,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {


                  trackuser=false;

                      final GoogleMapController controller = await _controller
                          .future;



                    //  trackuser=true;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: LatLng(ongoingJob.LoadingLat,ongoingJob.LoadingLng),
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


          Positioned(
            right: 20.0,
            bottom: _fabHeight-15,
            child: FloatingActionButton(
              child: Icon(
                fab_icon,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                getLocation();
               if( _pc.isPanelOpen){

                  fab_icon =Icons.gps_fixed;
                  _pc.close();
                  setState(() {

                 });

               }
              },
              backgroundColor: Colors.white,
            ),
          ),

          Visibility(
            visible: fab_visible,
            child: Positioned(
                bottom: 15,
                right: 15,
                child:  FloatingActionButton(
                  onPressed: (){
                    if(traderRequestPackagesloaded){
                      traderRequestPackagesloaded=false;
                      setState(() {

                      });
                    }else{
                    addjobRequest();
                    }
                  },

                  child:
                  traderRequestPackagesloaded?
                  Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                  ):Icon(
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
   Future<ui.Image> getImageFromPath(String path) async {

    final File imageFile = await DefaultCacheManager().getSingleFile(path);

 
     Uint8List imageBytes = imageFile.readAsBytesSync();

     final Completer<ui.Image> completer = new Completer();

     ui.decodeImageFromList(imageBytes, (ui.Image img) {
       return completer.complete(img);
     });

     return completer.future;
   }

   Future<BitmapDescriptor> getMarkerIcon( Size size ,String path) async {
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
     ui.Image image = await getImageFromPath(path); // Alternatively use your own method to get the image
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
             jobRequestsloaded&&jobRequests!=null?
             traderRequestPackagesloaded?
                 Padding(
           padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),

           child: ListView.builder(
           controller: list_sc,
               itemCount: traderRequestPackages.length,

               itemBuilder: (BuildContext context, int index) {
                 return   Column(
                   children: <Widget>[
                     index==0?
                     Column(
                       children: [
                         SizedBox(height: 16.0),
                         Text(
                           "Trader Requests",
                           style: TextStyle(
                             fontSize: 24.0,
                             fontWeight: FontWeight.w700,
                           ),
                         ),
                         SizedBox(height: 26.0),
                       ],
                     ):SizedBox(),

                     Stack(
                       children: <Widget>[
                         Column(
                           children: <Widget>[
                             SizedBox(height: 15.0),
                             Row(
                               mainAxisAlignment: MainAxisAlignment
                                   .start,
                               crossAxisAlignment: CrossAxisAlignment
                                   .center,
                               children: <Widget>[
                                 SizedBox(width: 10,),
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
                                     child: traderRequestPackages[index].trader.PhotoURL==null ? Icon(Icons.account_circle,color: Colors.grey,size: 0,) :  Image.network(traderRequestPackages[index].trader.PhotoURL,fit: BoxFit.cover)
                                     ,

                                   ),
                                 ),
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
                                             Icon(Icons.timer,
                                               color: Colors.blueAccent, size: 25,),
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
                                                   '${traderRequestPackages[index].traderRequest.CargoWeight}',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
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
                                             Icon(Icons.calendar_today,
                                               color: Colors.blueAccent, size: 25,),
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
                                                   '${traderRequestPackages[index].traderRequest.LoadingDate}',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
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
                                               color: Colors.blueAccent, size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Accpeted Delay",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${traderRequestPackages[index].traderRequest.AcceptedDelay} hours',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
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
                                               color: Colors.blueAccent, size: 25,),
                                             SizedBox(width: 5),
                                             Column(
                                               mainAxisAlignment: MainAxisAlignment.start,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[

                                                 Text("Trader",
                                                   style: TextStyle(
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                                 Text(
                                                   '${traderRequestPackages[index].trader.FirstName}  ${traderRequestPackages[index].trader.LastName}',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
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
                                               color: Colors.blueAccent, size: 25,),
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
                                                   '${traderRequestPackages[index].traderRequest.CargoType}',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
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
                                               color: Colors.blueAccent, size: 25,),
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
                                                 traderRequestPackages[index].traderRequest.EntryExit==0?
                                                 Text("Not Required",
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ):
                                                 Text("Required",
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w800,
                                                     color: AppTheme.grey,
                                                     fontSize: 12,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ],
                                         ),

                                       ],),

                                   ],
                                 ),
                               ],
                             ),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: <Widget>[

                                 Align(
                                   alignment: Alignment.bottomCenter,
                                   child: FlatButton(
                                     onPressed: () {
                                       //   Navigator.of(context).pop();
                                       viewTrader(traderRequestPackages[index].traderRequest.TraderID);
                                     },
                                     child: Text("Profile"),
                                   ),
                                 ),

                                 Align(
                                   alignment: Alignment.bottomRight,
                                   child: FlatButton(
                                     onPressed: () {
                                       // Navigator.of(context).pop();
                                       selectTrader(traderRequestPackages[index].traderRequest.TraderRequestID,traderRequestPackages[index].traderRequest.Selected);
                                     },

                                     child:
                                     traderRequestPackages[index].traderRequest.Selected==0?
                                     Text("Select",
                                       style: TextStyle(
                                         fontWeight: FontWeight.w800,
                                         color: Colors.green,
                                         fontSize: 12,
                                       ),
                                     ):
                                     Text("DeSelect",
                                       style: TextStyle(
                                         fontWeight: FontWeight.w800,
                                         color: Colors.redAccent,
                                         fontSize: 12,
                                       ),
                                     ),
                                   ),
                                 ),
                               ],

                             ),
                           ],
                         ),
                         traderRequestPackages[index].traderRequest.Selected!=0?
                         Positioned(
                           right: 0,
                           top: -15,
                           child: InkWell(
                             // When the user taps the button, show a snackbar.

                             child: Container(
                               padding: EdgeInsets.all(12.0),
                               child: Column(
                                 children: <Widget>[

                                   Icon(Icons.done,
                                     color: Colors.green, size: 25,),
                                 ],
                               ),
                             ),
                           ),
                         ):SizedBox(),
                       ],
                     ),


                   ],
                 );
               }

           ),
         ):
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

                                             Row(
                                               children: <Widget>[
                                                 InkWell(
                                                   // When the user taps the button, show a snackbar.
                                                   onTap: () {
                                                     //     pr.show();
                                                     deleteRequest(jobRequests[index].JobRequestID);
                                                   },
                                                   child: Container(
                                                     padding: EdgeInsets.all(12.0),
                                                     child: Column(
                                                       children: <Widget>[

                                                         Icon(Icons.cancel,
                                                           color: Colors.redAccent, size: 25,),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                                 Row(
                                                   mainAxisAlignment: MainAxisAlignment
                                                       .start,
                                                   crossAxisAlignment: CrossAxisAlignment
                                                       .start,
                                                   children: <Widget>[


                                                     Container(
                                                       width: 160,
                                                       child: Column(
                                                         mainAxisAlignment: MainAxisAlignment
                                                             .start,
                                                         crossAxisAlignment: CrossAxisAlignment
                                                             .start,

                                                         children: <Widget>[

                                                           SizedBox(height: 30),



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
                                                                     '${jobRequests[index].TripType}',
                                                                     style: TextStyle(
                                                                       fontWeight: FontWeight.w800,
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
                                                                 color: Colors.blueAccent, size: 25,),
                                                               SizedBox(width: 5),

                                                               Column(
                                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                                 crossAxisAlignment: CrossAxisAlignment.start,

                                                                 children: <Widget>[

                                                                   Text("Posted at",
                                                                     style: TextStyle(
                                                                       color: AppTheme.grey,
                                                                       fontSize: 12,
                                                                     ),
                                                                   ),
                                                                   Text('${jobRequests[index].TimeCreated.split("T")[1].substring(0,5)
                                                                   }',
                                                                     style: TextStyle(
                                                                       fontWeight: FontWeight.w800,
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

                                                                   Text("Unloading",
                                                                     style: TextStyle(
                                                                       color: AppTheme.grey,
                                                                       fontSize: 12,
                                                                     ),
                                                                   ),
                                                                   Container(
                                                                     width:100,
                                                                     child: Text(
                                                                       '${jobRequests[index].UnloadingPlace}',
                                                                       maxLines: 4,
                                                                       style: TextStyle(
                                                                         fontWeight: FontWeight.w800,
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
                                                     ),

                                                     SizedBox(width: 10),
                                                     Column(
                                                       mainAxisAlignment: MainAxisAlignment
                                                           .start,
                                                       crossAxisAlignment: CrossAxisAlignment
                                                           .start,

                                                       children: <Widget>[



                                                         SizedBox(height: 30),
                                                         Row(
                                                           mainAxisAlignment: MainAxisAlignment.start,
                                                           crossAxisAlignment: CrossAxisAlignment.start,
                                                           children: <Widget>[
                                                             Container(
                                                                 decoration:BoxDecoration(
                                                                   color: Colors.blueAccent,
                                                                   shape: BoxShape.circle,
                                                                 ),
                                                                 child: Padding(

                                                                     padding: EdgeInsets.all(5),
                                                                     child: Text("SR",style: TextStyle(color: Colors.white,fontSize: 13),))),

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
                                                                   '${jobRequests[index].Price}',
                                                                   style: TextStyle(
                                                                     fontWeight: FontWeight.w800,
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
                                                               color: Colors.blueAccent, size: 25,),
                                                             SizedBox(width: 5),
                                                             Column(
                                                               mainAxisAlignment: MainAxisAlignment.start,
                                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                               children: <Widget>[

                                                                 Text("Posted On",
                                                                   style: TextStyle(
                                                                     color: AppTheme.grey,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                                 Text('${jobRequests[index].TimeCreated.split("T")[0]
                                                                 }',
                                                                   style: TextStyle(
                                                                     fontWeight: FontWeight.w800,
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

                                                                 Text("Loading",
                                                                   style: TextStyle(
                                                                     color: AppTheme.grey,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                                 Container(
                                                                   width:100,
                                                                   child: Text(
                                                                     '${jobRequests[index].LoadingPlace}',
                                                                     maxLines:4,
                                                                     style: TextStyle(
                                                                       fontWeight: FontWeight.w800,
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


                                                   ],
                                                 ),
                                               ],
                                             ),


                                     Positioned(
                                       right: 5,
                                       top: 8,
                                       child: InkWell(
                                         // When the user taps the button, show a snackbar.
                                         onTap: () {
                                           //     pr.show();





                                           RequestedTrader=jobRequests[index].JobRequestID;
                                           showTraderRequest(jobRequests[index].JobRequestID);
                                         },
                                         child: Container(
                                           padding: EdgeInsets.all(8.0),
                                           child: Column(
                                             children: <Widget>[
                                               jobRequests[index].NumberOfTraderRequests>0?
                                               Badge(
                                                 badgeColor:Colors.blue[900],
                                                 shape: BadgeShape.circle,
                                                 borderRadius: 90,
                                                 toAnimate: false,
                                                 badgeContent: Padding(
                                                     padding: EdgeInsets.all(3.0),
                                                     child: Text('${jobRequests[index].NumberOfTraderRequests}',style: TextStyle(color: Colors.white),)),
                                                 child: Column(
                                                   children: <Widget>[
                                                    Icon(Icons.more_horiz,
                                                         color: Colors.black, size: 25,),
                                                      Text("Requests",style: TextStyle(color: Colors.black),),
                                                   ],
                                                 ),
                                               ):SizedBox()

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
             jobOfferloaded&&jobOffers!=null?
             Padding(
               padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),
               child: jobOffers != null ? ListView.builder(
                   controller: list_sc,
                   itemCount: jobOffers.length,

                   itemBuilder: (BuildContext context, int index) {
                     return GestureDetector(
                       onTap: (){
                         jobOffermore(index);
                       },
                       child: Padding(
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
                           key: ValueKey(jobOffers[index]),
                           child:  Stack(
                             children: <Widget>[

                               Column(
                                 mainAxisAlignment: MainAxisAlignment
                                     .center,
                                 crossAxisAlignment: CrossAxisAlignment
                                     .center,
                                 children: <Widget>[
                                   SizedBox(height: 15),
                                   Text(
                                     '${jobOffers[index].trader.FirstName}  ${jobOffers[index].trader.LastName}',
                                     style: TextStyle(
                                       fontWeight: FontWeight.w800,
                                       color: AppTheme.grey,
                                       fontSize: 18,
                                     ),
                                   ),
                                   SizedBox(height: 20),
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
                                           child: jobOffers[index].trader.PhotoURL==null ? Icon(Icons.account_circle,color: Colors.grey,size: 0,) :  Image.network(jobOffers[index].trader.PhotoURL,fit: BoxFit.cover)
                                           ,

                                         ),
                                       ),
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
                                                   Container(
                                                       decoration:BoxDecoration(
                                                         color: Colors.amber[700],
                                                         shape: BoxShape.circle,
                                                       ),
                                                       child: Padding(

                                                           padding: EdgeInsets.all(5),
                                                           child: Text("SR",style: TextStyle(color: Colors.white,fontSize: 13),))),


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
                                                         '${jobOffers[index].jobOffer
                                                             .Price}',
                                                         style: TextStyle(
                                                           fontWeight: FontWeight.w800,
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
                                                   Icon(Icons.calendar_today,
                                                     color: Colors.amber[700], size: 25,),
                                                   SizedBox(width: 5),
                                                   Column(
                                                     mainAxisAlignment: MainAxisAlignment.start,
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: <Widget>[

                                                       Text("Posted On",
                                                         style: TextStyle(
                                                           color: AppTheme.grey,
                                                           fontSize: 12,
                                                         ),
                                                       ),
                                                       Text(
                                                         '${jobOffers[index].jobOffer
                                                             .TimeCreated.split("T")[0]}',
                                                         style: TextStyle(
                                                           fontWeight: FontWeight.w800,
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

                                                       Text("Loading",
                                                         style: TextStyle(
                                                           color: AppTheme.grey,
                                                           fontSize: 12,
                                                         ),
                                                       ),
                                                       Container(
                                                         width:100,
                                                         child: Text(
                                                           '${jobOffers[index].jobOffer.LoadingPlace}',
                                                           maxLines: 4,
                                                           style: TextStyle(
                                                             fontWeight: FontWeight.w800,
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
                                                 .center,
                                             crossAxisAlignment: CrossAxisAlignment
                                                 .start,
                                             children: <Widget>[




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
                                                         '${jobOffers[index].jobOffer.TripType}',
                                                         style: TextStyle(
                                                           fontWeight: FontWeight.w800,
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
                                                         '${jobOffers[index].jobOffer.CargoWeight}',
                                                         style: TextStyle(
                                                           fontWeight: FontWeight.w800,
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

                                                       Text("Unloading",
                                                         style: TextStyle(
                                                           color: AppTheme.grey,
                                                           fontSize: 12,
                                                         ),
                                                       ),
                                                       Container(
                                                         width: 100,
                                                         child: Text(
                                                           '${jobOffers[index].jobOffer.UnloadingPlace}',
                                                           maxLines: 4,

                                                           style: TextStyle(
                                                             fontWeight: FontWeight.w800,
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
                                   jobOffers[index].jobOffer.JobOfferType=="Fixed-Price"?
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.end,
                                     children: <Widget>[
                                       jobOffers[index].driverRequest==null?
                                       Align(
                                         alignment: Alignment.bottomLeft,
                                         child: FlatButton(
                                           onPressed: () {
                                             addDriverRequestURL(jobOffers[index].jobOffer.JobOfferID,null);
                                           },
                                           child: Text("Send Request"),
                                         ),
                                       ):
                                       Align(
                                         alignment: Alignment.bottomLeft,
                                         child: FlatButton(
                                           onPressed: () {
                                             deleteDriverRequestofffer(jobOffers[index].jobOffer.JobOfferID);
                                           },
                                           child: Text("Cancel Request"),
                                         ),
                                       )

                                     ],

                                   ):

                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.end,
                                     children: <Widget>[
                                       jobOffers[index].driverRequest==null?
                                       Align(
                                         alignment: Alignment.bottomLeft,
                                         child: FlatButton(
                                           onPressed: () {

                                             displayBidDialogue(context,index);
                                           },
                                           child: Text("Bid"),
                                         ),
                                       ):
                                       Align(
                                         alignment: Alignment.bottomLeft,
                                         child: FlatButton(
                                           onPressed: () {
                                             deleteDriverRequestofffer(jobOffers[index].jobOffer.JobOfferID);
                                           },
                                           child: Text("Cancel Bid"),
                                         ),
                                       )

                                     ],

                                   ),
                                 ],
                               ),


                               jobOffers[index].driverRequest!=null?
                               Positioned(
                                 right: -5,
                                 top: -5,
                                 child: InkWell(
                                   // When the user taps the button, show a snackbar.
                                   onTap: () {
                                     //     pr.show();
                                 //    deleteRequest(jobOffers[index].JobRequestID);
                                   },
                                   child: Container(
                                     padding: EdgeInsets.all(12.0),
                                     child: Column(
                                       children: <Widget>[

                                         Icon(Icons.done,
                                           color: Colors.green, size: 25,),
                                          Text("Sent",style: TextStyle(color: Colors.green),)

                                       ],
                                     ),
                                   ),
                                 ),
                               ):SizedBox(),


                             ],
                           ),

                         ),
                       ),
                     );
                   }

               ) : SizedBox(height: 1.0,),

             ):
             jobOfferloaded?
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
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),

                               SizedBox(height: 5),

                               Text('${ongoingJob
                                   .CargoType}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .CargoWeight}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),



                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingPlace}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .UnloadingPlace}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingDate}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .LoadingTime}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),

                               ongoingJob
                                   .EntryExit==0?
                               Icon(Icons.close,
                                 color: Colors.red[500], size: 20,):
                               Icon(Icons.done,
                                 color: Colors.green[500], size: 20,),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .AcceptedDelay} Hours',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .JobOfferType}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),


                               SizedBox(height: 5),
                               Text('${ongoingJob
                                   .Price}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.w800,
                                   color: AppTheme.grey,
                                   fontSize: 12,
                                 ),
                               ),
                               SizedBox(height: 5),

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

                              loadObjections(ongoingJob.OnGoingJobID);
                            },
                            child: Text( "Objections",style: TextStyle(color: Colors.white),),
                          ),
                        ),

                        SizedBox(height: 10),
                          SizedBox(
                            width:200,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),

                              ),

                              color: primaryDark,
                              onPressed: () async {
                                //   await loginUser();
                                viewTrader(ongoingJob.TraderID);
                              },
                              child: Text( "View Trader",style: TextStyle(color: Colors.white),),
                            ),
                          ),

                        SizedBox(height: 10),

                        Visibility(
                          visible: ongoingJob.CompletedByDriver==0?true:false,
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
                              child: Text( "Mark as Complete",style: TextStyle(color: Colors.white),),
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
                         child:  Column(
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


                                     SizedBox(height: 10),



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

                                     Text(" Ratting",
                                       style: TextStyle(
                                         color: AppTheme.grey,
                                         fontSize: 12,
                                       ),
                                     ),
                                     //compleatedJobs[index].driverReview.Rating.toString())/20
                                     IgnorePointer(
                                       ignoring: true,
                                       child: RatingBar(
                                         onRatingChanged: (rating) => setState(() =>  _rating = rating),
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
                             SizedBox(),


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
                                     Container(
                                       width: screenWidth(context)*0.8,
                                       child: Text(
                                         '${compleatedJobs[index].driverReview
                                             .Review}',
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
                             ):SizedBox(),
                             SizedBox(height: 20),


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
  String dropdownValue = 'One Way';

  List <String> spinnerItems = [
    'One Way',
    'Two Way',
  ] ;
  FocusNode focusNodeloadingPlace,focusNodeunloadingPlace,focusNodePrice,_focusNodebid,focusNodeWaitingTime;

  final GlobalKey<FormState> _formJobRequestKey = GlobalKey<FormState>();
  _displayJobRequestDialog(BuildContext context) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: requestdialogContent(context),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }
  final myController = TextEditingController();
  final waitingtimeController = TextEditingController();

  String loadingPlace,unloadingPlace,tripType,Price,waitingtime;
  LatLng loadinglatlon,unloadinglatlon;
  requestdialogContent(BuildContext context) {
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
                    "Add Job Request",
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
                        Icon(Icons.file_upload),
                        Container(
                          width: screenWidth(context)*0.5,
                          child: TextFormField(
                            cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                            keyboardType: TextInputType.text,
                            initialValue: loadingPlace,
                            onTap:()  {

                              addLoadLocation();

                            },
                            onSaved: (String value) {
                              if(!value.isEmpty)
                                loadingPlace = value;
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
                            initialValue: unloadingPlace,
                            onTap: ()  {

                              addUnloadLocation();

                            },
                            onSaved: (String value) {
                              if(!value.isEmpty)
                                unloadingPlace = value;
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
                  Container(
                    margin: EdgeInsets.only(bottom: 18.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.access_time),
                        Container(
                          width: screenWidth(context)*0.5,
                          child: TextFormField(
                            controller: waitingtimeController,
                            cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                            keyboardType: TextInputType.number,
                             onTap:()  {

                             // addLoadLocation();

                            },

                            validator: (String value) {
                              if(value.length == null)
                                return 'Enter Waiting Time';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),

                              labelText: "Waiting Time",

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
                          width: screenWidth(context)*0.5,
                          child: TextFormField(
                            controller: myController,
                            cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                            keyboardType: TextInputType.number,

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

                            _displayJobRequestDialog(context);


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
                            waitingtime="";
                            loadingPlace="";
                            unloadingPlace="";
                            Price="";
                            tripType="";
                            myController.text="";
                            waitingtimeController.text="";
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
                            waitingtime=waitingtimeController.text;
                            uploadjobRequest();
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

  Future<void> deleteRequest(int jobRequestID) async {
    print("Deleting Request $jobRequestID");

    final client = HttpClient();
    showLoadingDialogue("Deleting Request");
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deleteDriverRequestURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);


    //   request.write('{"Token": "'+DriverProfile.getUserToken()+'","PermitLicenceID": "$permitLicenceID"}');
    request.write('{"JobRequestID": "$jobRequestID"}');

    final response = await request.close();


    response.transform(convert.utf8.decoder).listen((contents) async {
      print(contents);


      hideLoadingDialogue();
      ToastUtils.showCustomToast(context, "Request Deleted", true);

      setState(() {
        loadjobRequests();

      });


    });
  }catch(e){

  print(e);
  ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
  //pr.hide();

  }
  }

  void addjobRequest() {
    _displayJobRequestDialog(context);
  }
  Future<void> uploadjobRequest() async {
    print("Adding Job Request");
    showLoadingDialogue("Adding Job Request");


    final client = HttpClient();
     try{
      final request = await client.postUrl(Uri.parse(URLs.addJobRequestURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);



     //  LoadingPlace, LoadingLat, LoadingLng, UnloadingPlace, UnloadingLat, UnloadingLng, TripType, Price, WaitingTime

      request.write('{"UnloadingLng": "${unloadinglatlon.longitude}","UnloadingLat": "${unloadinglatlon.latitude}","LoadingLng": "${loadinglatlon.longitude}","LoadingLat": "${loadinglatlon.latitude}","LoadingPlace": "'+loadingPlace+'","UnloadingPlace": "'+unloadingPlace+'","TripType": "'+dropdownValue+'","Price": "$Price","WaitingTime":"$waitingtime"}');


      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);


        hideLoadingDialogue();
        ToastUtils.showCustomToast(context, "Job Request Added", true);

        setState(() {
          waitingtime="";
          loadingPlace="";
          unloadingPlace="";
          Price="";
          tripType="";
          myController.text="";
          waitingtimeController.text="";
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

  Future<void> completeJob() async {
    print("Mark as Complete");

    final client = HttpClient();
    showLoadingDialogue("Marking as Complete");
    try{
      final request = await client.postUrl(Uri.parse(URLs.driverfinishJobURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);



      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);

 
        locationDbRef.keepSynced(false);
        hideLoadingDialogue();
        ToastUtils.showCustomToast(context, "Job Marked Completed", true);

        setState(() {
          ongoingJob=null;
          loadonGoingJob();
        });


      });
    }catch(e){

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



                             Text("Posted By: ",
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

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

                            Text(
                              '${jobOffers[index].trader.FirstName}  ${jobOffers[index].trader.LastName}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text('${jobOffers[index].jobOffer.TripType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text('${jobOffers[index].jobOffer
                                .CargoType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .CargoWeight}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),



                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .LoadingPlace}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .UnloadingPlace}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .LoadingDate}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .LoadingTime}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),

                            jobOffers[index].jobOffer
                                .EntryExit==0?
                            Text('Not Required',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ):
                            Text('Required',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .AcceptedDelay} Hours',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .JobOfferType}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),


                            SizedBox(height: 5),
                            Text('${jobOffers[index].jobOffer
                                .Price}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
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
                            child: Text("Dismiss"),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FlatButton(
                            onPressed: () {
                            //  Navigator.of(context).pop();

                              viewTrader(jobOffers[index].jobOffer.TraderID);
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


  int RequestedTrader=null;
  bool traderRequestPackagesloaded = false;
  Future<void> showTraderRequest(int id) async {
    print("Loading TraderRequestPackages");
    showLoadingDialogue("Loading Requests");



    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getTraderRequestPackagesURL()+"?JobRequestID=$id ", headers:requestHeaders);

      if (response.statusCode == 200) {

        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);


        //   print(contents);
        if(jobRequestsMap["TraderRequestPackages"]!= null) {

          DataStream.traderRequestPackages =DataStream.parseTraderRequestPackages(jobRequestsMap["TraderRequestPackages"]);
          print(jobRequestsMap["TraderRequestPackages"]);
          traderRequestPackages = DataStream.traderRequestPackages;

        }

        print(jobRequestsMap["RequestSelected"]);


        traderRequestPackagesloaded=true;

        hideLoadingDialogue();
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

  Future<void> selectTrader(int traderRequestID,int selected) async {
    print("Toggle $traderRequestID - $selected");

    final client = HttpClient();
    showLoadingDialogue("Loading");
    try{
      final request = await client.postUrl(Uri.parse(URLs.toggleSelectTraderRequestURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      if(selected==0){
        request.write('{"TraderRequestID": "$traderRequestID","Selected": "1"}');
        print("1");
      }else{
        print("0");
        request.write('{"TraderRequestID": "$traderRequestID","Selected": "0"}');
      }


      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {
        print(contents);
        hideLoadingDialogue();
        showTraderRequest(RequestedTrader);
        ToastUtils.showCustomToast(context, "Request Toggled", true);

        setState(() {
        });

      });
      //  permits = DriverProfile.getPermit();
    }catch(e){

      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }

  Future<void> addDriverRequestURL(int jobOfferID,int price) async {
    print("addDriverRequestURL $jobOfferID");

    final client = HttpClient();
    showLoadingDialogue("Sending Request");
    try{
      final request = await client.postUrl(Uri.parse(URLs.addDriverRequestURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);

      if(price==null) {
        request.write('{"JobOfferID": "$jobOfferID","Price": null}');
      }else{
        request.write('{"JobOfferID": "$jobOfferID","Price": "$price"}');

      }
      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {

        print(contents);

        hideLoadingDialogue();
        ToastUtils.showCustomToast(context, "Request Sent", true);

        setState(() {
          loadjobOffers();
        });

      });
      //  permits = DriverProfile.getPermit();
    }catch(e){

      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }

  Future<void> deleteDriverRequestofffer(int jobOfferID) async {
    print("addDriverRequestURL $jobOfferID");

    final client = HttpClient();
    showLoadingDialogue("Canceling Request");
    try{
      final request = await client.deleteUrl(Uri.parse(URLs.deleteDriverRequestoffferURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


        request.write('{"JobOfferID": "$jobOfferID"}');

      final response = await request.close();


      response.transform(convert.utf8.decoder).listen((contents) async {

        print(contents);

        hideLoadingDialogue();
        ToastUtils.showCustomToast(context, "Canceling Request", true);

        setState(() {
          loadjobOffers();
        });

      });
      //  permits = DriverProfile.getPermit();
    }catch(e){

      print(e);
      ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
      //pr.hide();

    }
  }
  displayBidDialogue(BuildContext context,int index) {
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: biddialogContent(context, index),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);

  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String bid;
  biddialogContent(BuildContext context,int index) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
                      "Add Bid",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 26.0),


                    // SizedBox(height: 16.0),
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

                                padding: EdgeInsets.all(8),
                                  child: Text("SR",style: TextStyle(color: Colors.white),))),
                           Container(
                            width: screenWidth(context)*0.5,
                            child: TextFormField(
                              cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                              keyboardType: TextInputType.text,
                              initialValue: bid,
                              onSaved: (String value) {
                                if(!value.isEmpty)
                                  bid = value;
                              },
                              validator: (String value) {
                                if(value.length == null)
                                  return 'Enter Bid';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),

                                labelText: "Bid",

                              ),
                              focusNode: _focusNodebid,
                            ),
                          ),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: _focusNodebid.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
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
                              bid="";

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
                            //  pr.show();

                              final FormState form = _formKey.currentState;
                              form.save();
                              addDriverRequestURL(jobOffers[index].jobOffer.JobOfferID,int.parse(bid));


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
      loadingPlace = result.address;
      loadinglatlon=result.latLng;
      Navigator.of(context).pop();

      _displayJobRequestDialog(context);
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
      unloadingPlace = result.address;
      unloadinglatlon=result.latLng;
      Navigator.of(context).pop();

      _displayJobRequestDialog(context);
    }
  }

  Future<void> viewTrader(int id) async {


    showLoadingDialogue("Loading Trader Profile");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };

    try{
    final response = await http.get(URLs.getTraderProfileURL()+"?TraderID=${id}", headers:requestHeaders);

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
        child: traderProfiledialogContent(context,new TraderProfile.fromJson(map["Trader"])),
      );

      showDialog(context: context, builder: (BuildContext context) => dialog);



    }


    }catch(e){

      print(e.toString());
      hideLoadingDialogue();

    }








  }
  traderProfiledialogContent(BuildContext context,TraderProfile trader) {
    return SingleChildScrollView(
      child: Stack(
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
                    "${trader.FirstName} ${trader.LastName}",
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
                                    '${trader.Nationality}',
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
                                    '${trader.DateOfBirth}',
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
                                      '${trader.Email}',
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
                                    '${trader.Gender}',
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
                                    '${trader.PhoneNumber}',
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
                                      '${trader.Address}',
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
                        child:trader.PhotoURL==null?Icon(Icons.account_circle,size: 200,color: Colors.grey,):  Image.network(trader.PhotoURL,fit: BoxFit.cover)


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

  List<Objection> objection;
  Future<void> loadObjections(int id) async {
    print("Loading Job Objections");
    showLoadingDialogue("Loading Job Objections");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization':"JWT "+DataStream.token
    };
    final response = await http.get(URLs.getJobObjectionPackagesURL()+"?OnGoingJobID=${id}", headers:requestHeaders);

    if (response.statusCode == 200) {

      var jsonResponse = convert.jsonDecode(response.body);
    //  print(jsonResponse);
      Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);

      if(jobRequestsMap["JobObjections"]!= null) {
        DataStream.objection =DataStream.parseObjection(jobRequestsMap["JobObjections"]);
        print(jobRequestsMap["JobObjections"]);
        objection = DataStream.objection;

      }else{
        objection=null;
      }

      hideLoadingDialogue();
      setState(() {
      });
    }
  }
}

