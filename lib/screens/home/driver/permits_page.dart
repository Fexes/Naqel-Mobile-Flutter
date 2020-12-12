
      import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
      import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/models/driver/Permit.dart';
import 'package:naqelapp/utilts/DataStream.dart';
       import 'package:naqelapp/models/driver/DriverProfile.dart';
      import 'package:naqelapp/styles/app_theme.dart';
      import 'package:naqelapp/styles/styles.dart';
import 'package:naqelapp/utilts/AppException.dart';
import 'package:naqelapp/utilts/URLs.dart';
import 'package:naqelapp/utilts/UI/toast_utility.dart';
import 'package:progress_dialog/progress_dialog.dart';

      import '../../../models/driver/DriverProfile.dart';
       import 'package:async/async.dart';
      import 'dart:io';
      import 'package:http/http.dart' as http;
      class PermitPage extends StatefulWidget  {


        const PermitPage({Key key}) : super(key: key);



        @override
        _PermitPageState createState() => _PermitPageState();
      }

      class _PermitPageState extends State<PermitPage>  {

        List<Permit>  permits;

        FocusNode _focusNodepermitnumber,_focusNodepermitCode,_focusNodepermitPlace;
        @override
        void initState() {
          super.initState();

          loadPermits();

          _focusNodepermitnumber = new FocusNode();
          _focusNodepermitnumber.addListener(_onOnFocusNodeEvent);

          _focusNodepermitCode = new FocusNode();
          _focusNodepermitCode.addListener(_onOnFocusNodeEvent);


          _focusNodepermitPlace = new FocusNode();
          _focusNodepermitPlace.addListener(_onOnFocusNodeEvent);
        }
        _onOnFocusNodeEvent() {
          setState(() {
            // Re-renders
          });
        }
        @override
        void dispose() {
          super.dispose();
        }

        bool dataloaded = false;


        Future<void> loadPermits() async {
          final client = HttpClient();
          try{
          final request = await client.getUrl(Uri.parse(URLs.getPermitLicences()));
          request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
          request.headers.add("Authorization", "JWT "+DataStream.token);

          final response = await request.close();


          response.transform(utf8.decoder).listen((contents) async {

            //print(response.statusCode);
            Map<String, dynamic> TrailersMap = jsonDecode(contents) as Map<String, dynamic>;
            DataStream.permit = DataStream.parsePermit(TrailersMap["PermitLicences"]);
            print(TrailersMap["PermitLicences"]);
            permits=DataStream.permit;
            dataloaded=true;

            setState(() {
            });
          });
        }catch(e){

        print(e);
        ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
        //pr.hide();

        }
        //  permits = DriverProfile.getPermit();
        }



        File _image;

        Future getImage() async {
          var image = await ImagePicker.pickImage(source: ImageSource.gallery);
        // print(image.path);
          setState(() {
            _image = image;
          });

          _displayDialog(context);

        }
        DateTime selectedDate = DateTime.now();
        String dateSel = "Select Expiry Date";
        Future<Null> _selectDate(BuildContext context) async {
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


              dateSel=day+'-'+month+'-'+year;
          //   date_of_birth=dateSel;

              _displayDialog(context);
            });
        }

        _displayDialog(BuildContext context) {
          Dialog dialog= Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: dialogContent(context),
          );

          showDialog(context: context, builder: (BuildContext context) => dialog);

      }
        final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

      String PermitNumber,PhotoURL,ExpiryDate,Code,Place;
        dialogContent(BuildContext context) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                            "Add New Permit",
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
                                  initialValue: PermitNumber,
                                  onSaved: (String value) {
                                    if(!value.isEmpty)
                                      PermitNumber = value;
                                  },
                                  validator: (String value) {
                                    if(value.length == null)
                                      return 'Enter Permit Number';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),

                                    labelText: "Permit Number",

                                  ),
                                  focusNode: _focusNodepermitnumber,
                                ),
                              ),
                            ],
                          ),
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: _focusNodepermitnumber.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
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
                                    initialValue: Code,
                                    onSaved: (String value) {
                                      if(!value.isEmpty)
                                        Code = value;
                                    },
                                    validator: (String value) {
                                      if(value.length == null)
                                        return 'Enter Permit Code';
                                      else
                                        return null;
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),

                                      labelText: "Permit Code",

                                    ),
                                    focusNode: _focusNodepermitCode,
                                  ),
                                ),
                              ],
                            ),
                            decoration: new BoxDecoration(
                              border: new Border(
                                bottom: _focusNodepermitCode.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                                BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                              ),
                            ),
                          ),
                        // SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.only(bottom: 18.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.place),
                                Container(
                                  width: screenWidth(context)*0.5,
                                  child: TextFormField(
                                    cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                    keyboardType: TextInputType.text,
                                    initialValue: Place,
                                    onSaved: (String value) {
                                      if(!value.isEmpty)
                                        Place = value;
                                    },
                                    validator: (String value) {
                                      if(value.length == null)
                                        return 'Enter Permit Place';
                                      else
                                        return null;
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),

                                      labelText: "Permit Place",

                                    ),
                                    focusNode: _focusNodepermitPlace,
                                  ),
                                ),
                              ],
                            ),
                            decoration: new BoxDecoration(
                              border: new Border(
                                bottom: _focusNodepermitPlace.hasFocus ? BorderSide(color: Colors.black, style: BorderStyle.solid, width: 2.0) :
                                BorderSide(color: Colors.black.withOpacity(0.7), style: BorderStyle.solid, width: 1.0),
                              ),
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

                                    child: Text(dateSel,textAlign: TextAlign.start,),
                                    onPressed: () {
                                      final FormState form = _formKey.currentState;
                                      form.save();
                                      Navigator.of(context).pop();
                                      _selectDate(context);
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
                                    Code="";
                                    Place="";
                                    PermitNumber="";
                                    dateSel="Select Expiry Date";
                                    _image=null;
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

                                    final FormState form = _formKey.currentState;
                                    form.save();
                                    UploadData();
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
                        final FormState form = _formKey.currentState;
                        form.save();
                        getImage();
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
                                child: _image == null
                                    ?    Icon(Icons.add,color: Colors.white,size: 130,)

                                    : Image.file(_image,fit: BoxFit.cover),

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
        ProgressDialog pr;
        @override
        Widget build(BuildContext context) {
          pr = new ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: true);
          pr.style(
              message: '     Updating Permits...',
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
              child:Text('Loading Permits',style: TextStyle(color: Colors.black),),
            );

          }else {
            return Align(

                child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,

                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Permits',
                              style: TextStyle(color: Colors.black),),
                          ]
                      ),
                    ),
                    backgroundColor: Color(0xffF7F7F7),
                    body: SingleChildScrollView(

                      child: Stack(
                        alignment: Alignment.bottomRight,

                        children: <Widget>[


                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              const SizedBox(
                                height: 30,
                              ),
                              Container(
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height) - 110,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child:
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: permits.length,

                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        return Padding(
                                          padding: EdgeInsets.all(8),

                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                shape: BoxShape.rectangle,
                                                borderRadius: new BorderRadius
                                                    .only(
                                                  topLeft: const Radius
                                                      .circular(10.0),
                                                  topRight: const Radius
                                                      .circular(10.0),
                                                  bottomLeft: const Radius
                                                      .circular(10.0),
                                                  bottomRight: const Radius
                                                      .circular(10.0),
                                                ),
                                                boxShadow: [BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.15),
                                                  blurRadius: 8.0,
                                                )
                                                ]
                                            ),
                                            key: ValueKey(permits[index]),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start,
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,

                                              children: <Widget>[

                                                Padding(
                                                  padding: EdgeInsets.all(10),

                                                  child: Row(

                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,


                                                    children: <Widget>[
                                                      InkWell(
                                                        // When the user taps the button, show a snackbar.
                                                        onTap: () {
                                                          pr.show();
                                                          deletePermit(
                                                              permits[index]
                                                                  .PermitLicenceID);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .all(12.0),
                                                          child: Icon(Icons
                                                              .cancel,
                                                            color: Colors.redAccent,
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
                                                                .all(
                                                                Radius.circular(
                                                                    8)),
                                                            child: Image
                                                                .network(
                                                                permits[index]
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
                                                                  "Number: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  "Code: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  "Place: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  "Expiry: ",
                                                                  style: TextStyle(
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  '${permits[index]
                                                                      .PermitNumber}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  '${permits[index]
                                                                      .Code}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  '${permits[index]
                                                                      .Place}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
                                                                    fontSize: 12,
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
                                                                  '${permits[index]
                                                                      .ExpiryDate}',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w800,
                                                                    color: AppTheme
                                                                        .grey,
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
                                                ),
                                                SizedBox(height: 10),

                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                  )


                              )
                            ],
                          ),
                          Positioned(
                            bottom: 35,
                            right: 15,
                            child: FloatingActionButton(

                              onPressed: () {
                                _displayDialog(context);
                              },
                              backgroundColor: Colors.black,
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    )

                ),

            );
          }
        }

        Future<void> UploadData() async {
          try {
            print("Uploading picture");
            String fileName = this?._image.path
                ?.split("/")
                ?.last;
            StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
                .child("Permits")
                .child(fileName);
            StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
            StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
            taskSnapshot.ref.getDownloadURL();

            String s = await (await uploadTask.onComplete).ref.getDownloadURL();
            PhotoURL = s;
            print(s);

            addPermits(context);
          }catch(e){
        ToastUtils.showCustomToast(
        context, "Updated Failed", false);
        }
        }
        Future addPermits(BuildContext context) async {


          pr.show();


          final client = HttpClient();
          try{
          final request = await client.postUrl(Uri.parse(URLs.addPermitsURl()));
          request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
          request.headers.add("Authorization", "JWT "+DataStream.token);


          request.write('{"PermitNumber": "$PermitNumber", "PhotoURL": "' + PhotoURL + '", "ExpiryDate": "'+dateSel+'", "Code": "$Code", "Place": "$Place"}');
        //  request.write('{"PermitNumber": "'+PermitNumber+'", "PhotoURL": "' + PhotoURL + '", "ExpiryDate": "'+dateSel+'", "Code": "'+Code+'", "Place": "' + Place + '"}');

          final response = await request.close();

           response.transform(utf8.decoder).listen((contents) async {
             print(contents);
             pr.hide();


             _image = null;
             setState(() {
               Code="";
               Place="";
               PermitNumber="";
               loadPermits();
               //    loadData();

             });
           });


        }catch(e){

        print(e);
        ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
        //pr.hide();

        }

        }

  Future<void> deletePermit(int permitLicenceID) async {


    print("Deleting Permit $permitLicenceID");

    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.deletePermitURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);


 //   request.write('{"Token": "'+DriverProfile.getUserToken()+'","PermitLicenceID": "$permitLicenceID"}');
    request.write('{"PermitLicenceID": "$permitLicenceID"}');

    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);

      Map<String, dynamic> updateMap = jsonDecode(contents) as Map<String, dynamic>;


      pr.hide();



      _image=null;
      setState(() {
        loadPermits();
     //   DecodeToken(updateMap["Token"]);
     //   loadData();
      });


    });
  }catch(e){

        print(e);
        ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
        //pr.hide();

        }
  }


      }

