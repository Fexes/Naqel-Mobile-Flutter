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
import 'package:naqelapp/models/TransportCompany/TransportCompanyTrucks.dart';
import 'package:naqelapp/models/commons/CompletedJob.dart';
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





class CompanyHomePage extends StatefulWidget {
  const CompanyHomePage({Key key}) : super(key: key);

  @override
  _CompanyHomePageState createState() => _CompanyHomePageState();
}
class _CompanyHomePageState extends State<CompanyHomePage>  {
  ScrollController _controllerddd = ScrollController();

   Completer<GoogleMapController> _controller = Completer();
  static LatLng latLng =LatLng(0, 0,);
   PanelController _pc = new PanelController();


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



  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

  }


  int tab_postion=0;
 bool fab_visible = false;
  @override
  void initState(){
    super.initState();
    _fabHeight = _initFabHeight;

    Future.delayed(Duration.zero, () {
      this.loadTrucks();
    });

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

  bool trucksloaded =false;
  List<TransportCompanyTrucks> transportCompanyTrucks;
  Future<void> loadTrucks() async {

    showLoadingDialogue("Loading Trucks");

    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getTransportCompanyResponsiblegetTrucksURL(), headers:requestHeaders);

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);

      //  print(jsonResponse);

        Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);
        DataStream.transportCompanyTrucks = DataStream.parseTCtrucks(jobRequestsMap["Trucks"]);
      //  print(jobRequestsMap["Trucks"]);
        transportCompanyTrucks=DataStream.transportCompanyTrucks;
     //   dataloaded=true;

        trucksloaded=true;

        for(int i=0;i<=transportCompanyTrucks.length-1;i++) {
          final locationDbRef = FirebaseDatabase.instance.reference().child(
              "${transportCompanyTrucks[i].DriverID}");
          locationDbRef.once().then((value) async {
            try {
            String location = value.value["latlong"];
            print(location);


              final GoogleMapController controller = await _controller.future;

              LatLng driverLocation = new LatLng(
                  double.parse(location.split(',')[0]),
                  double.parse(location.split(',')[1]));
              _addDriverPin(transportCompanyTrucks[i].DriverID, driverLocation,
                  controller,transportCompanyTrucks[i].PhotoURL);
            }catch(e){

            }
          });

          locationDbRef.onChildChanged.listen((event) async {
            //  print(event.snapshot.value);
            try {
            String location = event.snapshot.value;

            final GoogleMapController controller = await _controller.future;

            LatLng driverLocation = new LatLng(
                double.parse(location.split(',')[0]),
                double.parse(location.split(',')[1]));
            _addDriverPin(
                transportCompanyTrucks[i].DriverID, driverLocation, controller,transportCompanyTrucks[i].PhotoURL);
          }catch(e){

            }
          });
        }

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
    //  permits = DriverProfile.getPermit();
  }






  LatLng userPosition;
   Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS



bool trackDriver=false;
  Future<void> _addDriverPin(int id,LatLng p,GoogleMapController controller,String imageURL) async {


    var markerIdVald = "${id}";
    final MarkerId markerIdd = MarkerId(markerIdVald);

    // creating a new MARKER
    final Marker markerd = Marker(
      icon: await getMarkerIcon( Size(150.0, 150.0),imageURL),
      //   icon: BitmapDescriptor.fromBytes(markerImageBytes),
      markerId: markerIdd,
     // infoWindow: InfoWindow(title: '${ DataStream.ongoingJob.driver.FirstName} ${ DataStream.ongoingJob.driver.LastName}' ),
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
                    Future.delayed(Duration.zero, () {
                      this.loadTrucks();
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
                           _pc.open();

                          setState(() {

                          });
                        },
                        child: Column(
                          children: <Widget>[
                         Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon( Icons.airport_shuttle,color: Colors.white,),
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

                            Text("Trucks",style: TextStyle(color: tab_postion==1||tab_postion==0?Colors.blue[600]:Colors.grey),),
                          ],

                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          print("offers clicker");
                          tab_postion=2;

                          _pc.open();
                          setState(() {

                          });
                        },
                        child: Column(
                          children: <Widget>[

                             Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon( Icons.work,color: Colors.white,),
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

                            Text("Truck Jobs",style: TextStyle(color: tab_postion==2||tab_postion==0?Colors.amber[700]:Colors.grey),),
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

                fab_visible=true;
                setState(() {

                });


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
            visible: fab_visible,
            child: Positioned(
              right: 20.0,
              bottom: _fabHeight-15,
              child: FloatingActionButton(
                child: Icon(
                  fab_icon,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                //  getLocation();
                  if( _pc.isPanelOpen){
                    fab_visible=true;
                  //  fab_icon =Icons.gps_fixed;
                    _pc.close();
                    setState(() {

                    });
                  }
                },
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
            trucksloaded&&transportCompanyTrucks!=null?
            Padding(
              padding: EdgeInsets.fromLTRB(0, _panelHeightClosed, 0, 0),
              child: transportCompanyTrucks != null ? ListView.builder(
                  controller: list_sc,
                  itemCount: transportCompanyTrucks.length,

                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: (){
                   //     jobOffermore(index);
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
                          key: ValueKey(transportCompanyTrucks[index]),
                          child:  Stack(
                            children: <Widget>[


                                          Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                                      child: Container(
                                                        height: 130,
                                                        width: 130,
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
                                                          const BorderRadius.all(Radius.circular(15)),
                                                          child:   Image.network(transportCompanyTrucks[index].PhotoURL,fit: BoxFit.cover),

                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(width: 30,),
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
                                                                  color: Colors.amber[700], size: 25,),
                                                                SizedBox(width: 5),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[

                                                                    Text("Truck Number",
                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '${transportCompanyTrucks[index].TruckNumber}',
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


                                                        SizedBox(height: 10,),


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

                                                                Text("Model",
                                                                  style: TextStyle(
                                                                    color: AppTheme.grey,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${transportCompanyTrucks[index].Model}',
                                                                  maxLines: 4,
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

                                                        SizedBox(height: 10,),

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

                                                                Text("Brand",
                                                                  style: TextStyle(
                                                                    color: AppTheme.grey,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${transportCompanyTrucks[index].Brand}',
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
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.bottomLeft,
                                                      child: FlatButton(
                                                        onPressed: () {

                                                        },
                                                        child: Text("Details"),
                                                      ),
                                                    ) ,
                                                    Align(
                                                      alignment: Alignment.bottomLeft,
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          viewDriver(transportCompanyTrucks[index].DriverID);
                                                        },
                                                        child: Text("Driver"),
                                                      ),
                                                    )

                                                  ],

                                                ),
                                              ],
                                            ),
                                          ),





                            ],
                          ),

                        ),
                      ),
                    );
                  }

              ) : SizedBox(height: 1.0,),

            ):
            trucksloaded?
            Container(
                alignment: Alignment.center,
                child: Text("No Job Offers found",style: TextStyle(color:Colors.amber[700]),)
            ):
            //trucksloaded
            Container(
                alignment: Alignment.center,
                child:  Text("Loading Offers",style: TextStyle(color:Colors.amber[700]),)
            ):SizedBox(),


            // Job Offers

          ],

        )
    );
  }






}

