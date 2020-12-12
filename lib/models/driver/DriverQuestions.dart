class DriverQuestions{

  int DriverQuestionID;
  int DriverID;
  String QuestionNumber;
  String Question;
  String Class;
  String Created;
  AskedBy askedBy;
  DriverAnswer driverAnswer;

  DriverQuestions({
    this.DriverQuestionID,
    this.DriverID,
    this.QuestionNumber,
    this.Question,
    this.Class,
    this.Created,
    this.askedBy,
    this.driverAnswer,
  });
  factory DriverQuestions.fromJson(Map<String, dynamic> parsedJson){
    return DriverQuestions(
      DriverQuestionID : parsedJson['DriverQuestionID'],
      DriverID : parsedJson ['DriverID'],
      QuestionNumber : parsedJson ['QuestionNumber'],
      Question : parsedJson['Question'],
      Class : parsedJson ['Class'],
      Created : parsedJson ['Created'],
      askedBy :AskedBy.fromJson(parsedJson["AskedBy"]),
      driverAnswer :DriverAnswer.fromJson(parsedJson["DriverAnswer"]),

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
      FirstName : parsedJson['FirstName'],
      LastName : parsedJson ['LastName'],
      Username : parsedJson ['Username'],
    );
  }

}
class DriverAnswer{
  int DriverAnswerID;
  int DriverQuestionID;
  int AdministratorID;
  String Answer;
  int Edited;
  String Created;
  AnsweredBy answeredBy;


  DriverAnswer({
    this.DriverAnswerID,
    this.DriverQuestionID,
    this.AdministratorID,
    this.Answer,
    this.Edited,
    this.Created,
    this.answeredBy
  });

  factory DriverAnswer.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null){
    return DriverAnswer(
      DriverAnswerID : parsedJson['DriverAnswerID'],
      DriverQuestionID : parsedJson ['DriverQuestionID'],
      AdministratorID : parsedJson ['AdministratorID'],
      Answer : parsedJson['Answer'],
      Edited : parsedJson ['Edited'],
      Created : parsedJson ['Created'],
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

      FirstName : parsedJson['FirstName'],
      LastName : parsedJson ['LastName'],
      Username : parsedJson ['Username'],
    );}else{
      return null;
    }
  }

}