
      import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
      import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/models/driver/DriverQuestions.dart';
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
      class QuestionsPage extends StatefulWidget  {


        const QuestionsPage({Key key}) : super(key: key);



        @override
        _PermitPageState createState() => _PermitPageState();
      }

      class _PermitPageState extends State<QuestionsPage>  {

        List<DriverQuestions>  questions;

        FocusNode _focusNodepermitnumber,_focusNodepermitCode,_focusNodepermitPlace;
        @override
        void initState() {
          super.initState();

          loadQuestions();

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


        Future<void> loadQuestions() async {
          final client = HttpClient();
          try{
          final request = await client.getUrl(Uri.parse(URLs.drivergetQuestionsURL()));
          request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
          request.headers.add("Authorization", "JWT "+DataStream.token);

          final response = await request.close();


          response.transform(utf8.decoder).listen((contents) async {

            //print(response.statusCode);
            Map<String, dynamic> map = jsonDecode(contents) as Map<String, dynamic>;
            DataStream.questions = DataStream.parseQuestions(map["Questions"]);
            print(map["Questions"]);
            questions=DataStream.questions;
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

        String question;
         dialogContent(BuildContext context) {
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
                            "Ask a Question",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.0),


                        // SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.only(bottom: 18.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.help_outline),
                                Container(
                                  width: screenWidth(context)*0.6,
                                  child: TextFormField(
                                    cursorColor: Colors.black, cursorRadius: Radius.circular(1.0), cursorWidth: 1.0,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    initialValue: question,
                                    onSaved: (String value) {
                                      if(!value.isEmpty)
                                        question = value;
                                    },
                                    validator: (String value) {
                                      if(value.length == null)
                                        return 'Enter Question';
                                      else
                                        return null;
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10.0, right: 0.0, top: 10.0, bottom: 12.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),

                                      labelText: "Question",

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


                        // SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomRight,
                                child: FlatButton(
                                  onPressed: () {
                                    question="";

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
                                    addQuestion();
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
              child:Text('Loading Questions',style: TextStyle(color: Colors.black),),
            );

          }else {
            return Align(

                child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,

                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('Questions',
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
                                      itemCount: questions.length,

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
                                              key: ValueKey(questions[index]),
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
                                                            deleteQuestion(
                                                                questions[index]
                                                                    .DriverQuestionID);
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

                                                                        Text("Asker By",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w800,
                                                                            color: AppTheme.grey,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${questions[index].askedBy.FirstName} ${questions[index].askedBy.LastName}',
                                                                          style: TextStyle(
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
                                                                    Icon(Icons.help_outline,
                                                                      color: Colors.teal, size: 25,),
                                                                    SizedBox(width: 5),
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: <Widget>[

                                                                        Text("Question",
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
                                                                            '${questions[index].Question}',
                                                                            overflow: TextOverflow.ellipsis,
                                                                            maxLines: 100,
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
                                                                questions[index].driverAnswer!=null?
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

                                                                        Text("Answered By",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w800,
                                                                            color: AppTheme.grey,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${questions[index].driverAnswer.answeredBy.FirstName} ${questions[index].driverAnswer.answeredBy.LastName}',
                                                                          style: TextStyle(
                                                                            color: AppTheme.grey,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ):SizedBox(),
                                                                SizedBox(height: 10,),
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

                                                                        Container(
                                                                          width: screenWidth(context)*0.7,
                                                                          child:
                                                                          questions[index].driverAnswer!=null?
                                                                          Text(
                                                                            '${questions[index].driverAnswer.Answer}',
                                                                            overflow: TextOverflow.ellipsis,
                                                                            maxLines: 100,
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
                                                              ],),

                                                          ],
                                                        ),
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

        Future addQuestion() async {

          print("addQuestion");
       //   pr.show();


          final client = HttpClient();
          try{
          final request = await client.postUrl(Uri.parse(URLs.driveraddQuestionURL()));
          request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
          request.headers.add("Authorization", "JWT "+DataStream.token);


          request.write('{"Question": "$question"}');

          final response = await request.close();

           response.transform(utf8.decoder).listen((contents) async {
             print(contents);


 
             setState(() {
               pr.hide();
               question="";
               loadQuestions();
               //    loadData();

             });
           });


        }catch(e){

        print(e);
        ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
        //pr.hide();

        }

        }

  Future<void> deleteQuestion(int id) async {


    print("Deleting Question $id");

    final client = HttpClient();
    try{
    final request = await client.deleteUrl(Uri.parse(URLs.driverdeleteQuestionURL()));
    request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    request.headers.add("Authorization", "JWT "+DataStream.token);


 //   request.write('{"Token": "'+DriverProfile.getUserToken()+'","PermitLicenceID": "$permitLicenceID"}');
    request.write('{"DriverQuestionID": "$id"}');

    final response = await request.close();

    response.transform(utf8.decoder).listen((contents) async {
      print(contents);

      pr.hide();

      setState(() {
        loadQuestions();
      });


    });
  }catch(e){

        print(e);
        ToastUtils.showCustomToast(context, "An Error Occurred. Try Again !", false);
        //pr.hide();

        }
  }


      }

