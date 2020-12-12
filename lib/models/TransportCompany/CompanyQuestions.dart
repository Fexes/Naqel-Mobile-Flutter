
class CompanyQuestions{

  int ResponsibleQuestionID;
  int TransportCompanyResponsibleID;
  String QuestionNumber;
  String Question;
  String Class;
  String Created;
  AskedBy askedBy;
  ResponsibleAnswer responsibleAnswer;

  CompanyQuestions({
    this.ResponsibleQuestionID,
    this.TransportCompanyResponsibleID,
    this.QuestionNumber,
    this.Question,
    this.Class,
    this.Created,
    this.askedBy,
    this.responsibleAnswer,
  });
  factory CompanyQuestions.fromJson(Map<String, dynamic> parsedJson){
    return CompanyQuestions(



      ResponsibleQuestionID : parsedJson['ResponsibleQuestionID']as int,
      TransportCompanyResponsibleID : parsedJson ['TransportCompanyResponsibleID'] as int,
      QuestionNumber : parsedJson ['QuestionNumber'] as String,
      Question : parsedJson['Question']as String,
      Class : parsedJson ['Class']as String,
      Created : parsedJson ['Created']as String,
      askedBy :AskedBy.fromJson(parsedJson["AskedBy"]),
      responsibleAnswer :ResponsibleAnswer.fromJson(parsedJson["ResponsibleAnswer"]),

    );
  }

}

class AskedBy {
  String Name;
  String Username;
  AskedBy({
    this.Name,
    this.Username,
  });
  factory AskedBy.fromJson(Map<String, dynamic> parsedJson){
    return AskedBy(
      Name : parsedJson ['Name']as String,
      Username : parsedJson ['Username']as String,
    );
  }

}
class ResponsibleAnswer{
  int ResponsibleAnswerID;
  int ResponsibleQuestionID;
  int AdministratorID;
  String Answer;
  int Edited;
  String Created;
  AnsweredBy answeredBy;


  ResponsibleAnswer({
    this.ResponsibleAnswerID,
    this.ResponsibleQuestionID,
    this.AdministratorID,
    this.Answer,
    this.Edited,
    this.Created,
    this.answeredBy
  });

  factory ResponsibleAnswer.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null){
    return ResponsibleAnswer(
      ResponsibleAnswerID : parsedJson['ResponsibleAnswerID']as int,
      ResponsibleQuestionID : parsedJson ['ResponsibleQuestionID']as int,
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