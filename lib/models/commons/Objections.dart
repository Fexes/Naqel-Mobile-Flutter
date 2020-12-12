class Objection {

  int JobObjectionID;
  int OnGoingJobID;
  int DriverID;
  int TraderID;
  String Reason;
  String Comment;
  ObjectionBy objectionBy;
  String Created;

  Objection({
    this.JobObjectionID,
    this.OnGoingJobID,
    this.DriverID,
    this.TraderID,
    this.Reason,
    this.Comment,
    this.objectionBy,
    this.Created,

  });
  factory Objection.fromJson(Map<String, dynamic> parsedJson){
    return Objection(
      JobObjectionID : parsedJson['JobObjectionID'],
      OnGoingJobID : parsedJson ['OnGoingJobID'],
      DriverID : parsedJson ['DriverID'],
      TraderID : parsedJson['TraderID'],
      Reason : parsedJson ['Reason'],
      Comment : parsedJson ['Comment'],
      Created : parsedJson ['Created'],
      objectionBy : ObjectionBy.fromJson(parsedJson["ObjectionBy"]),

    );
  }
  
}
class ObjectionBy {
  String FirstName;
  String LastName;
  String Username;
  String Type;
  ObjectionBy({
    this.FirstName,
    this.LastName,
    this.Username,
    this.Type,

  });
  factory ObjectionBy.fromJson(Map<String, dynamic> parsedJson){
    return ObjectionBy(
      FirstName : parsedJson['FirstName'],
      LastName : parsedJson ['LastName'],
      Username : parsedJson ['Username'],
      Type : parsedJson ['Type'],

    );
  }
}