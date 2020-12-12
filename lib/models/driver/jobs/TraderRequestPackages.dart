class TraderRequestPackages{

  TraderRequest traderRequest;
  Trader trader;

  TraderRequestPackages({
    this.traderRequest,
    this.trader,
  });

  factory TraderRequestPackages.fromJson(Map<String, dynamic> parsedJson){
    return TraderRequestPackages(
      traderRequest :TraderRequest.fromJson(parsedJson["TraderRequest"]),
      trader : Trader.fromJson(parsedJson["Trader"]),
    );
  }
}
class Trader {
  String FirstName;
  String LastName;
  String PhotoURL;
  Trader({
    this.FirstName,
    this.LastName,
    this.PhotoURL,
  });
  factory Trader.fromJson(Map<String, dynamic> parsedJson){
    return Trader(
      FirstName : parsedJson['FirstName'],
      LastName : parsedJson ['LastName'],
      PhotoURL : parsedJson ['PhotoURL'],
    );
  }


}
class TraderRequest {


  int TraderRequestID;
  int JobRequestID;
  int TraderID;
  int CargoWeight;
  int EntryExit;
  int AcceptedDelay;
  int Selected;
  String   CargoType ;
  String   LoadingDate ;
  String   LoadingTime ;
  String   Created ;


  TraderRequest({
    this.TraderRequestID,
    this.JobRequestID,
    this.TraderID,
    this.CargoWeight,
    this.EntryExit,
    this.AcceptedDelay,
    this.Selected,
    this.CargoType,
    this.LoadingDate,
    this.LoadingTime,
    this.Created,
  });

  factory TraderRequest.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null){
      return TraderRequest(

        TraderRequestID : parsedJson['TraderRequestID'],
        JobRequestID : parsedJson ['JobRequestID'],
        TraderID : parsedJson['TraderID'],
        CargoWeight : parsedJson ['CargoWeight'],
        EntryExit : parsedJson['EntryExit'],
        AcceptedDelay : parsedJson ['AcceptedDelay'],
        Selected : parsedJson['Selected'],
        CargoType : parsedJson ['CargoType'],
        LoadingDate : parsedJson['LoadingDate'],
        LoadingTime : parsedJson ['LoadingTime'],
        Created : parsedJson['Created'],

      );
    }else{
      return null;
    }
  }

}