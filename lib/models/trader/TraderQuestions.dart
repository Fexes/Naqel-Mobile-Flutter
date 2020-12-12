import 'package:naqelapp/models/driver/DriverQuestions.dart';

class TraderQuestions{

  int DriverQuestionID;
  int DriverID;
  String QuestionNumber;
  String Question;
  String Class;
  String Created;
  AskedBy askedBy;
  TraderAnswer traderAnswer;

  TraderQuestions({
    this.DriverQuestionID,
    this.DriverID,
    this.QuestionNumber,
    this.Question,
    this.Class,
    this.Created,
    this.askedBy,
    this.traderAnswer,
  });
  factory TraderQuestions.fromJson(Map<String, dynamic> parsedJson){
    return TraderQuestions(



      DriverQuestionID : parsedJson['DriverQuestionID']as int,
      DriverID : parsedJson ['DriverID'] as int,
      QuestionNumber : parsedJson ['QuestionNumber'] as String,
      Question : parsedJson['Question']as String,
      Class : parsedJson ['Class']as String,
      Created : parsedJson ['Created']as String,
      askedBy :AskedBy.fromJson(parsedJson["AskedBy"]),
      traderAnswer :TraderAnswer.fromJson(parsedJson["TraderAnswer"]),

    );
  }

}

class AskedBy {
  String FirstName;
  String LastName;
  String Username;
  AskedBy({
    this.FirstName,
    this.LastName,
    this.Username,
  });
  factory AskedBy.fromJson(Map<String, dynamic> parsedJson){
    return AskedBy(
      FirstName : parsedJson['FirstName']as String,
      LastName : parsedJson ['LastName']as String,
      Username : parsedJson ['Username']as String,
    );
  }

}
class TraderAnswer{
  int DriverAnswerID;
  int DriverQuestionID;
  int AdministratorID;
  String Answer;
  int Edited;
  String Created;
  AnsweredBy answeredBy;


  TraderAnswer({
    this.DriverAnswerID,
    this.DriverQuestionID,
    this.AdministratorID,
    this.Answer,
    this.Edited,
    this.Created,
    this.answeredBy
  });

  factory TraderAnswer.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null){
    return TraderAnswer(
      DriverAnswerID : parsedJson['DriverAnswerID']as int,
      DriverQuestionID : parsedJson ['DriverQuestionID']as int,
      AdministratorID : parsedJson ['AdministratorID']as int,
      Answer : parsedJson['Answer']as String,
      Edited : parsedJson ['Edited']as int,
      Created : parsedJson ['Created']as String,
      answeredBy :AnsweredBy.fromJson(parsedJson["AnsweredBy"]),

    );}else {
      return null;
    }
  }
}

class AnsweredBy {
  String FirstName;
  String LastName;
  String Username;
  AnsweredBy({
    this.FirstName,
    this.LastName,
    this.Username,
  });
  factory AnsweredBy.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null){
    return AnsweredBy(

      FirstName : parsedJson['FirstName']as String,
      LastName : parsedJson ['LastName']as String,
      Username : parsedJson ['Username']as String,
    );}else{
      return null;
    }
  }

}