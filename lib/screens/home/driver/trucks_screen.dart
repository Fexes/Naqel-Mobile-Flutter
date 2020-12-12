import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:naqelapp/utilts/DataStream.dart';
import 'package:naqelapp/models/driver/Trailer.dart';
import 'package:naqelapp/models/driver/Trucks.dart';
import 'package:naqelapp/styles/app_theme.dart';
import 'package:naqelapp/styles/styles.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../../utilts/URLs.dart';
import '../../../models/driver/DriverProfile.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class TruckPage extends StatefulWidget  {


  const TruckPage({Key key}) : super(key: key);



  @override
  _TruckPageState createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage>  {

  bool checkEmails = true;
  bool checkTerms = true;
  bool showText = true;
  FocusNode _focusNodeOwner,_focusNodeBrand,_focusNodeProductionYear,_focusNodeWeight,_focusNodeModel,_focusNodePlateNumber,_focusNodeType,_focusNodeTrailerType,_focusNodeTrailerWeight ;
  @override
  void initState() {
    super.initState();
    loadData();


    _focusNodeOwner = new FocusNode();
    _focusNodeOwner.addListener(_onOnFocusNodeEvent);


    _focusNodeBrand = new FocusNode();
    _focusNodeBrand.addListener(_onOnFocusNodeEvent);

    _focusNodeProductionYear = new FocusNode();
    _focusNodeProductionYear.addListener(_onOnFocusNodeEvent);

    _focusNodeWeight = new FocusNode();
    _focusNodeWeight.addListener(_onOnFocusNodeEvent);

    _focusNodeModel = new FocusNode();
    _focusNodeModel.addListener(_onOnFocusNodeEvent);

    _focusNodePlateNumber = new FocusNode();
    _focusNodePlateNumber.addListener(_onOnFocusNodeEvent);

    _focusNodeType = new FocusNode();
    _focusNodeType.addListener(_onOnFocusNodeEvent);

    _focusNodeTrailerType = new FocusNode();
    _focusNodeTrailerType.addListener(_onOnFocusNodeEvent);

    _focusNodeTrailerWeight = new FocusNode();
    _focusNodeTrailerWeight.addListener(_onOnFocusNodeEvent);
  }
  @override
  void dispose() {
    super.dispose();
    _focusNodeOwner.dispose();
  }
  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }
  String owner_name,brand_name,platenumber,truckmodel,trucktype,trailertype,trailerweight,weight,productionYear;
  int driver_id;
   var errorText;
  File _image,_image2;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
    setState(() {
      _image = image;
      if(_image!=null) {
        pr.show();
        uploadPic(_image,"TruckPhoto");
      }
    });
  }

  Future getTrailerImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
    setState(() {
      _image2 = image;

    });
  }
  void showPassword() {
    setState(() {
      showText =! showText;
    });
  }

  DateTime selectedDate = DateTime.now();
  String dateSel = "Select Date of Birth";
   int selectedRadio;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();




  int DriverID ;
  String TruckType ="";
  String Weight ;
  String OwnerName ="";
  String BrandName ="";
  String PlateNumber="";
  String ProductionYear ;
  String TruckModel ="";
  String PhotoURL="";

  bool dataloaded = false;

  List<Trailer>  trailers;

  bool truckexist=false;


  Future<Timer> loadData()  async {

    print("Loading Trucks");
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(URLs.getTruckUrl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    final response = await request.close();


    response.transform(utf8.decoder).listen((contents) async {

      dataloaded = true;

      print(contents);

      //   ToastUtils.showCustomToast(context, "Login successful",true);


      Map<String, dynamic> truckMap = jsonDecode(contents) as Map<
          String,
          dynamic>;

      if (truckMap["Truck"] != null){
        truckexist=true;
        DataStream.truck = new Trucks.fromJson(truckMap["Truck"]);
      print(truckMap["Truck"]);
      // pr.hide();


      TruckType = DataStream.truck.Type;
      PhotoURL = DataStream.truck.PhotoURL;
      Weight = DataStream.truck.MaximumWeight.toString();
      OwnerName = DataStream.truck.Owner;
      BrandName = DataStream.truck.Brand;
      PlateNumber = DataStream.truck.PlateNumber;
      ProductionYear = DataStream.truck.ProductionYear.toString();
      TruckModel = DataStream.truck.Model;


      trucktype = TruckType;
      driver_id = DriverID;
      owner_name = OwnerName;
      brand_name = BrandName;
      platenumber = PlateNumber;
      weight = Weight;
      truckmodel = TruckModel;
      productionYear = ProductionYear;

      setState(() {
       });
        loadTrailers();
    }else{
        setState(() {
          truckexist=false;

        });
      }
    });



//     trailers=DataStream.truck.getAllTrailers();

  }

  Future<void> loadTrailers() async {

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(URLs.getTrailersUrl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    final response = await request.close();


     response.transform(utf8.decoder).listen((contents) async {

      //print(response.statusCode);
       Map<String, dynamic> TrailersMap = jsonDecode(contents) as Map<String, dynamic>;
       if (TrailersMap["Trailers"] != null) {
         DataStream.trailers = DataStream.parseTrailer(TrailersMap["Trailers"]);
         print(TrailersMap["Trailers"]);
         trailers = DataStream.trailers;


         setState(() {});
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: true);
    pr.style(
        message: '     Updating Truck...',
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

    if(!dataloaded){

      return Align(
        child:Text('Loading Trucks',style: TextStyle(color: Colors.black),),
      );
    }else{

      if(truckexist) {
        Widget ownernameForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          width: screenWidth(context) * 0.35,
          child: Row(
            children: <Widget>[
              Icon(Icons.account_circle, color: Colors.black,),
              Container(
                width: (screenWidth(context) * 0.3) - 4,
                child: TextFormField(

                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty) {
                      owner_name = value;
                    }
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Please Enter Owner Name';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: DataStream.truck.Owner,
                    labelText: "Owner Name",
                  ),
                  focusNode: _focusNodeOwner,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeOwner.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget brandNameForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          width: screenWidth(context) * 0.35,
          child: Row(
            children: <Widget>[
              Icon(Icons.account_circle, color: Colors.black,),
              Container(
                width: (screenWidth(context) * 0.3) - 4,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,

                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      brand_name = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Please Enter Brand Name';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: DataStream.truck.Brand,
                    labelText: "Brand Name",
                  ),
                  focusNode: _focusNodeBrand,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeBrand.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget productionYearForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.account_circle, color: Colors.black,),
              Container(
                width: screenWidth(context) * 0.7,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,

                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      productionYear = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Please Enter Production Year';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: DataStream.truck.ProductionYear.toString(),
                    labelText: "Production Year",
                  ),
                  focusNode: _focusNodeProductionYear,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeProductionYear.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget weightFourm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.phone_android),
              Container(
                width: screenWidth(context) * 0.7,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      weight = value;
                  },
                  validator: (String value) {
                    if (value.length == null)
                      return 'Enter Maximum Weight';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),

                    hintText: DataStream.truck.MaximumWeight.toString(),
                    labelText: "Maximum Weight",

                  ),
                  focusNode: _focusNodeWeight,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeWeight.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget truckModelForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.home, color: Colors.black,),
              Container(
                width: screenWidth(context) * 0.7,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      truckmodel = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Please Enter Truck Model';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),

                    hintText: DataStream.truck.Model,
                    labelText: "Truck Model",
                  ),
                  focusNode: _focusNodeModel,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeModel.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget platenumberForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_airport, color: Colors.black,),
              Container(
                width: screenWidth(context) * 0.7,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      platenumber = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Plate Number';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: DataStream.truck.PlateNumber,
                    labelText: "Plate Number",
                  ),
                  focusNode: _focusNodePlateNumber,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodePlateNumber.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget truckTypeForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_airport, color: Colors.black,),
              Container(
                width: screenWidth(context) * 0.7,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      trucktype = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Truck Type';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: DataStream.truck.Type,
                    labelText: "Truck Type",
                  ),
                  focusNode: _focusNodeType,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeType.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget trailerWeightFourm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.phone_android),
              Container(
                width: screenWidth(context) * 0.5,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      trailerweight = value;
                  },
                  validator: (String value) {
                    if (value.length == null)
                      return 'Enter Maximum Weight';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),

                    labelText: "Maximum Weight",

                  ),
                  focusNode: _focusNodeTrailerWeight,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeTrailerWeight.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );

        Widget trailerTypeForm = Container(
          margin: EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_airport, color: Colors.black,),
              Container(
                width: screenWidth(context) * 0.5,
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(1.0),
                  cursorWidth: 1.0,
                  keyboardType: TextInputType.text,
                  onSaved: (String value) {
                    if (!value.isEmpty)
                      trailertype = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Trailer Type';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    labelText: "Trailer Type",
                  ),
                  focusNode: _focusNodeTrailerType,
                ),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border(
              bottom: _focusNodeTrailerType.hasFocus ? BorderSide(
                  color: Colors.black, style: BorderStyle.solid, width: 2.0) :
              BorderSide(color: Colors.black.withOpacity(0.7),
                  style: BorderStyle.solid,
                  width: 1.0),
            ),
          ),
        );


        ScrollController _scrollController = new ScrollController();


        return Align(


          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,

              title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Trucks', style: TextStyle(color: Colors.black),),
                  ]
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
                                        alignment: new Alignment(1, 1),
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Container(
                                              height: 280,
                                              width: 280,
                                              decoration: BoxDecoration(

                                                shape: BoxShape.rectangle,
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      color: AppTheme.grey
                                                          .withOpacity(0.6),
                                                      offset: const Offset(
                                                          2.0, 4.0),
                                                      blurRadius: 8),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                                child: _image == null
                                                    ? DataStream.truck
                                                    .PhotoURL == null ||
                                                    DataStream.truck.PhotoURL ==
                                                        ""
                                                    ? Icon(
                                                  Icons.airport_shuttle,
                                                  color: Colors.grey, size: 0,)
                                                    : Image.network(
                                                    DataStream.truck.PhotoURL,
                                                    fit: BoxFit.cover)

                                                    : Image.file(
                                                    _image, fit: BoxFit.cover),

                                              ),
                                            ),
                                          ),

                                          new Positioned(
                                            right: 10.0,
                                            bottom: 10.0,
                                            child: FloatingActionButton(
                                              onPressed: getImage,
                                              backgroundColor: Colors.black,
                                              tooltip: 'Pick Image',
                                              child: Icon(Icons.add_a_photo),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),


                                  SizedBox(height: 50),
                                  Row(
                                    children: <Widget>[

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Plate Number: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Owner Name: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Production Year: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Brand: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Truck Model: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Truck Type: ",
                                              style: TextStyle(
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text("Max Weight(GVM): ",
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
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.PlateNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.Owner,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.ProductionYear
                                                  .toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.Brand,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.Model,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.Type,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, left: 0),
                                            child: Text(
                                              DataStream.truck.MaximumWeight
                                                  .toString(),
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
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 0, 30, 0),
                                    child: Divider(
                                      height: 1,
                                      color: AppTheme.grey.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),


                                  Text(
                                    "Update Truck",
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
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        new Listener(
                                          child: new InkWell(
                                              child: updteDetails == true
                                                  ? Column(
                                                children: <Widget>[
                                                  Icon(Icons.contact_mail,
                                                    color: Colors.red,
                                                    size: 30,),
                                                  const SizedBox(height: 10,),
                                                  Text("Details",
                                                    style: TextStyle(
                                                        color: Colors.red),),
                                                  Text(
                                                    "                                                          ",
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.red,
                                                        decoration: TextDecoration
                                                            .underline,
                                                        decorationThickness: 5),),

                                                ],
                                              )
                                                  : Column(
                                                children: <Widget>[
                                                  Icon(Icons.contact_mail,
                                                    color: Colors.black,),
                                                  const SizedBox(height: 10,),
                                                  Text("Details",
                                                    style: TextStyle(
                                                        color: Colors.black),),

                                                ],
                                              ),
                                              onTap: () {
                                                _scrollController.animateTo(
                                                  500,
                                                  curve: Curves.easeOut,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                );
                                                setState(() {
                                                  if (updteDetails) {
                                                    updteDetails = false;
                                                  } else {
                                                    updteDetails = true;
                                                    TrailerDetails = false;
                                                  }
                                                });
                                              }
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: updteDetails,
                                    child: Container(

                                      alignment: AlignmentDirectional.topStart,
                                      padding: EdgeInsets.only(left: 16.0,
                                          top: 16.0,
                                          bottom: 4.0,
                                          right: 16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[

                                          Text("General Details",),
                                          SizedBox(height: 10,),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              ownernameForm,
                                              SizedBox(
                                                  width: (screenWidth(context) *
                                                      0.1) + 16),
                                              brandNameForm
                                            ],
                                          ),

                                          platenumberForm,
                                          weightFourm,
                                          truckModelForm,
                                          productionYearForm,
                                          truckTypeForm,


                                          DataStream.truck.TruckID == null ?
                                          Container(
                                            alignment: AlignmentDirectional
                                                .center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 12.0),
                                              child: SizedBox(
                                                width: 200,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius
                                                        .circular(18.0),

                                                  ),

                                                  color: primaryDark,
                                                  onPressed: () {
                                                    final FormState form = _formKey
                                                        .currentState;
                                                    form.save();

                                                    addTruck(context);
                                                  },
                                                  child: Text("Add Truck",
                                                    style: TextStyle(
                                                        color: Colors.white),),
                                                ),
                                              ),
                                            ),
                                          ) :

                                          Container(
                                            alignment: AlignmentDirectional
                                                .center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 12.0),
                                              child: SizedBox(
                                                width: 200,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius
                                                        .circular(18.0),

                                                  ),

                                                  color: primaryDark,
                                                  onPressed: () {
                                                    final FormState form = _formKey
                                                        .currentState;
                                                    form.save();

                                                    updateSettings(context);
                                                  },
                                                  child: Text("Update Truck",
                                                    style: TextStyle(
                                                        color: Colors.white),),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),


                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 0, 30, 0),
                                    child: Divider(
                                      height: 1,
                                      color: AppTheme.grey.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),


                                  Text(
                                    "Trailers",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.grey,
                                      fontSize: 26,
                                    ),),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  trailers != null ? Container(
                                      height: 210.0,
                                      child:
                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: trailers.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              key: ValueKey(trailers[index]),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,


                                                children: <Widget>[

                                                  Row(

                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,


                                                    children: <Widget>[
                                                      InkWell(
                                                        // When the user taps the button, show a snackbar.
                                                        onTap: () {
                                                          pr.show();
                                                          deleteTrailer(
                                                              trailers[index]
                                                                  .TrailerID);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .all(12.0),
                                                          child: Icon(
                                                            Icons.cancel,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 30,),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .fromLTRB(
                                                            0, 0, 0, 0),
                                                        child: Container(
                                                          height: 95,
                                                          width: 95,
                                                          decoration: BoxDecoration(

                                                            shape: BoxShape
                                                                .rectangle,
                                                            boxShadow: <
                                                                BoxShadow>[
                                                              BoxShadow(
                                                                  color: AppTheme
                                                                      .grey
                                                                      .withOpacity(
                                                                      0.6),
                                                                  offset: const Offset(
                                                                      2.0, 4.0),
                                                                  blurRadius: 8),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                            const BorderRadius
                                                                .all(Radius
                                                                .circular(8)),
                                                            child: Image
                                                                .network(
                                                                trailers[index]
                                                                    .PhotoURL,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),

                                                        ),
                                                      ),
                                                      SizedBox(width: 20),

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
                                                              Padding(

                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    left: 0),
                                                                child: Text(
                                                                  "Weight: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5),

                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    left: 0),
                                                                child: Text(
                                                                  "Type: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 14,
                                                                  ),
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
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    left: 0),
                                                                child: Text(
                                                                  '${trailers[index]
                                                                      .MaximumWeight}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5),

                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    left: 0),
                                                                child: Text(
                                                                  '${trailers[index]
                                                                      .Type}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),


                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    child: trailers.length <= 1
                                                        ? FloatingActionButton(

                                                      onPressed: () {
                                                        setState(() {
                                                          _scrollController
                                                              .animateTo(
                                                            600,
                                                            curve: Curves
                                                                .easeOut,
                                                            duration: const Duration(
                                                                milliseconds: 500),
                                                          );

                                                          if (TrailerDetails) {
                                                            TrailerDetails =
                                                            false;
                                                          } else {
                                                            TrailerDetails =
                                                            true;
                                                            updteDetails =
                                                            false;
                                                          }
                                                        });
                                                      },
                                                      backgroundColor: Colors
                                                          .black,
                                                      child: Icon(Icons.add),
                                                    )
                                                        :
                                                    const SizedBox(
                                                      height: 1,
                                                    ),
                                                  ),

                                                ],
                                              ),

                                            );
                                          }
                                      )


                                  ) : Container(
                                      child: FloatingActionButton(

                                        onPressed: () {
                                          setState(() {
                                            _scrollController.animateTo(
                                              600,
                                              curve: Curves.easeOut,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                            );

                                            if (TrailerDetails) {
                                              TrailerDetails = false;
                                            } else {
                                              TrailerDetails = true;
                                              updteDetails = false;
                                            }
                                          });
                                        },
                                        backgroundColor: Colors.black,
                                        child: Icon(Icons.add),
                                      )
                                  ),


                                  Visibility(
                                    visible: TrailerDetails,
                                    child: Container(

                                      alignment: AlignmentDirectional.topStart,
                                      padding: EdgeInsets.only(left: 16.0,
                                          top: 16.0,
                                          bottom: 4.0,
                                          right: 16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[

                                          Text("Trailer Details",),
                                          SizedBox(height: 10,),


                                          Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  getTrailerImage();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(0, 0, 0, 0),
                                                  child: Container(
                                                    height: 95,
                                                    width: 95,
                                                    decoration: BoxDecoration(

                                                      shape: BoxShape.rectangle,
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: AppTheme.grey
                                                                .withOpacity(
                                                                0.6),
                                                            blurRadius: 8),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(8)),
                                                      child: _image2 == null ?
                                                      Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 95,) :
                                                      Image.file(_image2,
                                                          fit: BoxFit.cover),
                                                    ),

                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20,),

                                              Column(
                                                children: <Widget>[
                                                  trailerTypeForm,
                                                  trailerWeightFourm,
                                                ],
                                              ),
                                            ],
                                          ),


                                          Container(
                                            alignment: AlignmentDirectional
                                                .center,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 12.0),
                                              child: SizedBox(
                                                width: 200,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: new BorderRadius
                                                        .circular(18.0),

                                                  ),

                                                  color: primaryDark,
                                                  onPressed: () {
                                                    final FormState form = _formKey
                                                        .currentState;
                                                    form.save();

                                                    if (_image2 != null) {
                                                      pr.show();
                                                      uploadPic(_image2,
                                                          "TrailerPhoto");
                                                    }
                                                  },
                                                  child: Text("Add Trailer",
                                                    style: TextStyle(
                                                        color: Colors.white),),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                )
            ),

          ),

        );
      }else{
        return Align(
          child:Text('No Truck Found',style: TextStyle(color: Colors.black),),
        );
      }
    }


  }
              bool isNumeric(String s) {
                if(s == null) {
                  return false;
                }

                return double.parse(s, (e) => null) != null ||
                    int.parse(s, onError: (e) => null) != null;
              }

              bool updteDetails=false;
              bool TrailerDetails=false;
              bool updteEmail=false;
              bool updtePAssword=false;

              ProgressDialog pr;
              Future addTruck(BuildContext context) async {


                  pr.show();

                  final client = HttpClient();


                  print(DataStream.truck.TruckID);
                   final request = await client.postUrl(Uri.parse(URLs.addTruckUrl()));


                  request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
                  request.headers.add("Authorization", "JWT "+DataStream.token);



                  request.write('{"PlateNumber": "$platenumber", "Owner": "' + owner_name + '", "ProductionYear": " $productionYear  ", "Brand": "'+brand_name+'", "Model": "'+truckmodel+'", "Type": "' + trucktype + '", "MaximumWeight": "$weight", "PhotoURL": ""}');
                 // request.write('{"Token": "","PlateNumber": "$platenumber", "Owner": "' + owner_name + '", "ProductionYear": " $productionYear  ", "Brand": "'+brand_name+'", "Model": "'+truckmodel+'", "Type": "' + trucktype + '", "MaximumWeight": "$weight", "PhotoURL": ""}');




                final response = await request.close();

                  response.transform(utf8.decoder).listen((contents) async {
                    print(contents);
                    pr.hide();

                    Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;

                    print(updateMap);
                    if(updateMap["Message"]=="Truck is updated in database."){



                    ToastUtils.showCustomToast(
                        context, "Detailes Updated Successfully", true);


                    }else{
                      ToastUtils.showCustomToast(
                          context, "Updated Failed", false);
                    }

                    _image = null;
                    setState(() {
                  //    DecodeToken(updateMap["Token"]);

                    });
                  });



              }

              Future updateSettings(BuildContext context) async {


                    pr.show();

                    final client = HttpClient();


                    print(DataStream.truck.TruckID);
                    final request = await client.postUrl(Uri.parse(URLs.updateTruckUrl()));


                    request.headers.set( HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");



                 //   request.write('{"Token": "' + DriverProfile.getUserToken() + '","PlateNumber": "$platenumber", "Owner": "' + owner_name + '", "ProductionYear": " $productionYear  ", "Brand": "'+brand_name+'", "Model": "'+truckmodel+'", "Type": "' + trucktype + '", "MaximumWeight": "$weight"}');
                    request.write('{"Token": "","PlateNumber": "$platenumber", "Owner": "' + owner_name + '", "ProductionYear": " $productionYear  ", "Brand": "'+brand_name+'", "Model": "'+truckmodel+'", "Type": "' + trucktype + '", "MaximumWeight": "$weight"}');




                    final response = await request.close();

                    response.transform(utf8.decoder).listen((contents) async {
                      print(contents);
                      pr.hide();

                      Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;

                      print(updateMap);
                      if(updateMap["Message"]=="Truck is updated in database."){



                        ToastUtils.showCustomToast(
                            context, "Detailes Updated Successfully", true);


                      }else{
                        ToastUtils.showCustomToast(
                            context, "Updated Failed", false);
                      }

                      _image = null;
                      setState(() {
                    //    DecodeToken(updateMap["Token"]);
                        loadData();

                      });
                    });



  }




               Future updatePicUrl(String s) async {



                print("Updating URL");

                final client = HttpClient();
                final request = await client.postUrl(Uri.parse(URLs.updateTruckPhotoUrlInDatabase()));
                request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
                request.headers.add("Authorization", "JWT "+DataStream.token);

              //  request.write('{"Token": "'+DriverProfile.getUserToken()+'","PhotoURL": "'+s+'"}');
                request.write('{"PhotoURL": "'+s+'"}');

                final response = await request.close();

                response.transform(utf8.decoder).listen((contents) async {
                  print(contents);

                  Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;




                  pr.hide();

                  _image=null;
                  setState(() {
                    DataStream.truck.PhotoURL=s;

                  });


                });


              }

  Future updateTrailerPicUrl(String s) async {



    print("Updating URL");

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(URLs.addTrailerURl()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);

    int id=DataStream.truck.TruckID;

   // request.write('{"Token": "'+DriverProfile.getUserToken()+'","MaximumWeight": "'+trailerweight+'","PhotoURL": "'+s+'","Type": "'+trailertype+'"}');
    request.write('{"MaximumWeight": "'+trailerweight+'","PhotoURL": "'+s+'","Type": "'+trailertype+'"}');

    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);

      Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;

      pr.hide();

      _image=null;
      setState(() {

        loadTrailers();

      });


    });


  }

  Future deleteTrailer(int id) async {



    print("Deleting Trailer $id");

    final client = HttpClient();
    final request = await client.deleteUrl(Uri.parse(URLs.deleteTrailerURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);


   // request.write('{"Token": "'+DriverProfile.getUserToken()+'","TrailerID": "$id"}');
    request.write('{"TrailerID": "$id"}');

    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);

      Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;


      pr.hide();



      _image=null;
      setState(() {
        loadTrailers();
       });


    });


  }

              Future uploadPic(File _image,String type) async{



                print("Uploading picture");
                String fileName = basename(_image.path);
                StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(type).child(fileName);
                StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
                StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
                taskSnapshot.ref.getDownloadURL();

                String s =await (await uploadTask.onComplete).ref.getDownloadURL();
                print (s);

             if(type.contains('TruckPhoto')) {
                  updatePicUrl(s);
                }else{
                  updateTrailerPicUrl(s);

                }


              }
}

