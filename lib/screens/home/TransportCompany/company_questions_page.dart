
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqelapp/models/TransportCompany/CompanyQuestions.dart';
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

import '../../../models/driver/DriverProfile.dart';
import 'package:async/async.dart';
import 'dart:io';


class CompanyQuestionsPage extends StatefulWidget  {


  const CompanyQuestionsPage({Key key}) : super(key: key);



  @override
  _CompanyQuestionsPageState createState() => _CompanyQuestionsPageState();
}

class _CompanyQuestionsPageState extends State<CompanyQuestionsPage>  {


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


  List<CompanyQuestions>  questions;

  FocusNode _focusNodepermitnumber,_focusNodepermitCode,_focusNodepermitPlace;
  @override
  void initState() {
    super.initState();



    _focusNodepermitnumber = new FocusNode();
    _focusNodepermitnumber.addListener(_onOnFocusNodeEvent);

    _focusNodepermitCode = new FocusNode();
    _focusNodepermitCode.addListener(_onOnFocusNodeEvent);


    _focusNodepermitPlace = new FocusNode();
    _focusNodepermitPlace.addListener(_onOnFocusNodeEvent);

    Future.delayed(Duration.zero, () {
      this.loadQuestions();
    });


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

    showLoadingDialogue("Loading questions");
    final client = HttpClient();
    try{

      Map<String, String> requestHeaders = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"JWT "+DataStream.token
      };
      final response = await http.get(URLs.getTransportCompanyResponsiblegetQuestionsURL(), headers:requestHeaders);

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);

        print(jsonResponse);

        Map<String, dynamic> jobRequestsMap = convert.jsonDecode(response.body);
        DataStream.companyQuestions = DataStream.parseCompanyQuestions(jobRequestsMap["Questions"]);
        print(jobRequestsMap["Questions"]);
        questions=DataStream.companyQuestions;
        dataloaded=true;

        hideLoadingDialogue();
        setState(() {
        });
      }


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

                          Container(
                            width: screenWidth(context)*0.7,
                            child:
                            questions[index].responsibleAnswer!=null?
                            Text(
                              '${questions[index].responsibleAnswer.Answer}',
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
  @override
  Widget build(BuildContext context) {


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
                  mainAxisAlignment: MainAxisAlignment.center,
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

                                                    deleteQuestion(
                                                        questions[index]
                                                            .ResponsibleQuestionID);
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

                                                                Text("Asked By",
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    color: AppTheme.grey,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${questions[index].askedBy.Name}',
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
                                                        questions[index].responsibleAnswer!=null?
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
                                                                  '${questions[index].responsibleAnswer.answeredBy.FirstName} ${questions[index].responsibleAnswer.answeredBy.LastName}',
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
                                                                  questions[index].responsibleAnswer!=null?
                                                                  Text(
                                                                    '${questions[index].responsibleAnswer.Answer}',
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
    showLoadingDialogue("Adding Question");


    final client = HttpClient();
    try{
      final request = await client.postUrl(Uri.parse(URLs.getTransportCompanyResponsibleaddQuestionURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


      request.write('{"Question": "$question"}');

      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);



        setState(() {
          hideLoadingDialogue();
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
    showLoadingDialogue("Deleting Question");

    final client = HttpClient();
    try{
      final request = await client.deleteUrl(Uri.parse(URLs.getTransportCompanyResponsibleadeleteQuestionURL()));
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add("Authorization", "JWT "+DataStream.token);


      //   request.write('{"Token": "'+DriverProfile.getUserToken()+'","PermitLicenceID": "$permitLicenceID"}');
      request.write('{"ResponsibleQuestionID": "$id"}');

      final response = await request.close();

      response.transform(utf8.decoder).listen((contents) async {
        print(contents);


        hideLoadingDialogue();
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

