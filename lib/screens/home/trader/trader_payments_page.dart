
      import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
      import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/models/commons/Bills.dart';
import 'package:naqelapp/models/driver/DriverQuestions.dart';
import 'package:naqelapp/models/driver/Permit.dart';
import 'package:naqelapp/models/trader/TraderQuestions.dart';
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
      class TraderPaymentsPage extends StatefulWidget  {


        const TraderPaymentsPage({Key key}) : super(key: key);



        @override
        _PermitPageState createState() => _PermitPageState();
      }

      class _PermitPageState extends State<TraderPaymentsPage>  {

        List<Bills>  bills;

        FocusNode _focusNodepermitnumber,_focusNodepermitCode,_focusNodepermitPlace;
        @override
        void initState() {
          super.initState();

          loadPayments();

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


        Future<void> loadPayments() async {
          final client = HttpClient();
          try{
          final request = await client.getUrl(Uri.parse(URLs.getTraderBillsURL()));
          request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
          request.headers.add("Authorization", "JWT "+DataStream.token);

          final response = await request.close();


          response.transform(utf8.decoder).listen((contents) async {

            print(response.statusCode);

            Map<String, dynamic> map = jsonDecode(contents) as Map<String, dynamic>;
            DataStream.bills = DataStream.parsepayments(map["Bills"]);
            print(map["Bills"]);
            bills=DataStream.bills;
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



        final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


        AnswerdialogContent(BuildContext context,int index) {
          return SingleChildScrollView(
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
                          "Answer",
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
                            Icon(Icons.question_answer,
                              color: Colors.teal, size: 25,),
                            SizedBox(width: 5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Text("Answer",
                                  style: TextStyle(
                                    color: AppTheme.grey,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),



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

                                  Navigator.of(context).pop(); // To close the dialog
                                },
                                child: Text("OK"),
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
        ProgressDialog pr;
        @override
        Widget build(BuildContext context) {
          pr = new ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: true);
          pr.style(
              message: '     Updating Questions...',
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
              child:Text('Loading Payments',style: TextStyle(color: Colors.black),),
            );

          }else {
            return Align(

                child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,

                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Payments',
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
                                      itemCount: bills.length,

                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        return GestureDetector(
                                          onTap: (){


                                          },
                                          child: Padding(
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
                                              key: ValueKey(bills[index]),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,

                                                children: <Widget>[
                                                  Column(
                                                    children: [
                                                      SizedBox(height: 20,),

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text("Bill Number : ",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: AppTheme.grey,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(bills[index].BillNumber,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: AppTheme.grey,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15,),
                                                  Padding(
                                                    padding: EdgeInsets.all(10),

                                                    child: Column(
                                                      children: [
                                                        Row(


                                                          children: <Widget>[


                                                            SizedBox(height: 10,),
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

                                                                    Text("Amount",
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      bills[index].Amount.toString(),
                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              ],
                                                            ),

                                                            SizedBox(width: 40,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Icon(Icons.help_outline,
                                                                  color: Colors.teal, size: 25,),
                                                                SizedBox(width: 5),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[

                                                                    Text("Jon Number",
                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),

                                                                    Container(
                                                                      width: screenWidth(context)*0.7,
                                                                      child:
                                                                      Text(
                                                                        bills[index].JobNumber,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 10,
                                                                        style: TextStyle(
                                                                          color: AppTheme.grey,
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 10,),



                                                          ],
                                                        ),
                                                        SizedBox(height: 15,),

                                                        Row(


                                                          children: [
                                                             Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Icon(Icons.supervised_user_circle,
                                                                  color: Colors.teal, size: 25,),
                                                                SizedBox(width: 5),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[

                                                                    Text("Status",
                                                                      style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                    bills[index].Paid==1?
                                                                    Text("Paid",
                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ):
                                                                    Text("Not Paid",

                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),


                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(width: 40,),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                Icon(Icons.question_answer,
                                                                  color: Colors.teal, size: 25,),
                                                                SizedBox(width: 5),
                                                                Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: <Widget>[

                                                                    Text("Generated on",
                                                                      style: TextStyle(
                                                                        color: AppTheme.grey,
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),

                                                                    Container(
                                                                      width: screenWidth(context)*0.7,
                                                                      child:
                                                                      bills[index]!=null?
                                                                      Text(
                                                                        bills[index].Created.split('T')[0]+"\n"+bills[index].Created.split('T')[1].substring(0,5),
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 5,
                                                                        style: TextStyle(
                                                                          color: AppTheme.grey,
                                                                          fontSize: 12,
                                                                        ),
                                                                      ):
                                                                      Text(
                                                                        'Question Not Answered yet',
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 1,
                                                                        style: TextStyle(
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
                                                        SizedBox(height: 15,),

                                                        Row(

                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [

                                                            FlatButton(

                                                              child: Text('Bill'),
                                                              onPressed: () async {

                                                              },
                                                            ),
                                                            !bills[index].HasPayProof?
                                                            FlatButton(
                                                              child: Text('Pay'),
                                                              onPressed: () async {

                                                              },
                                                            ):SizedBox(),
                                                            !bills[index].HasPayProof?
                                                            FlatButton(
                                                              child: Text('Upload Proof'),
                                                              onPressed: () async {

                                                              },
                                                            ):SizedBox(),

                                                            !bills[index].HasPayDetails?
                                                            FlatButton(
                                                              child: Text('Details'),
                                                              onPressed: () async {

                                                            //    viewBillData();

                                                                Dialog dialog = Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(60),
                                                                  ),
                                                                  elevation: 0.0,
                                                                  backgroundColor: Colors.transparent,
                                                                  child: paymentDetailsDialogue(bills[index]));

                                                                showDialog(context: context, builder: (BuildContext context) => dialog);
                                                              },
                                                            ):SizedBox(),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),

                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                  )


                              )
                            ],
                          ),

                        ],
                      ),
                    )

                ),

            );
          }
        }

        // Future<void> viewBillData(int id) async {
        //
        //
        //   showLoadingDialogue("Loading Trader Profile");
        //
        //   Map<String, String> requestHeaders = {
        //     'Content-type': 'application/json',
        //     'Accept': 'application/json',
        //     'Authorization':"JWT "+DataStream.token
        //   };
        //
        //   try{
        //     final response = await http.get(URLs.getTraderProfileURL()+"?TraderID=${id}", headers:requestHeaders);
        //
        //     if (response.statusCode == 200) {
        //       var jsonResponse = convert.jsonDecode(response.body);
        //
        //       print(jsonResponse);
        //
        //       Map<String, dynamic> map = convert.jsonDecode(response.body);
        //
        //
        //
        //       hideLoadingDialogue();
        //
        //       Dialog dialog = Dialog(
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(60),
        //         ),
        //         elevation: 0.0,
        //         backgroundColor: Colors.transparent,
        //         child: traderProfiledialogContent(context,new TraderProfile.fromJson(map["Trader"])),
        //       );
        //
        //       showDialog(context: context, builder: (BuildContext context) => dialog);
        //
        //
        //
        //     }
        //
        //
        //   }catch(e){
        //
        //     print(e.toString());
        //     hideLoadingDialogue();
        //
        //   }
        //
        //
        //
        //
        //
        //
        //
        //
        // }

        paymentDetailsDialogue(Bills bill) {
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
                          "ader.FirstName} rader.LastName}",
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
                                          'ader.Nationality}',
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
                                          'rader.DateOfBirth}',
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
                                            'trader.Email}',
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
                                          'rader.Gender}',
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
                                          'trader.PhoneNumber}',
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
                                            'trader.Address}',
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
                                child: Text("Delete"),
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
                              child:Icon(Icons.account_circle,size: 200,color: Colors.grey,)


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

