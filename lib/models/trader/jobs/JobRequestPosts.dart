class JobRequestPosts {
  JobRequestTrader jobRequestTrader;
  Driver driver;
  TraderRequest traderRequest;
  bool DriverOnJob;

  JobRequestPosts({
    this.jobRequestTrader,
    this.driver,
    this.traderRequest,
    this.DriverOnJob,
  });

  factory JobRequestPosts.fromJson(Map<String, dynamic> parsedJson){
    return JobRequestPosts(
      jobRequestTrader :JobRequestTrader.fromJson(parsedJson["JobRequest"]),
      driver : Driver.fromJson(parsedJson["Driver"]),
      traderRequest : TraderRequest.fromJson(parsedJson["TraderRequest"]),
      DriverOnJob : parsedJson ['DriverOnJob'],
    );
  }
}
class JobRequestTrader {


  int JobRequestID;
  int  DriverID;
  String Price;
  int WaitingTime;
  String   LoadingPlace ;
  String   UnloadingPlace ;
  String   TripType ;
  String   TimeCreated ;


  JobRequestTrader({
    this.JobRequestID,
    this.DriverID,
    this.Price,
    this.WaitingTime,
    this.LoadingPlace,
    this.UnloadingPlace,
    this.TripType,
    this.TimeCreated,
  });

  factory JobRequestTrader.fromJson(Map<String, dynamic> parsedJson){
    return JobRequestTrader(
      JobRequestID : parsedJson['JobRequestID'],
      DriverID : parsedJson ['DriverID'],
      Price : parsedJson['Price'].toString(),
      WaitingTime : parsedJson ['WaitingTime'],
      LoadingPlace : parsedJson['LoadingPlace'],
      UnloadingPlace : parsedJson ['UnloadingPlace'],
      TripType : parsedJson ['TripType'],
      TimeCreated : parsedJson ['TimeCreated'],
    );
  }
}
class Driver {
  String FirstName;
  String LastName;
  String PhotoURL;
  Driver({
    this.FirstName,
    this.LastName,
    this.PhotoURL,

  });
  factory Driver.fromJson(Map<String, dynamic> parsedJson){
    return Driver(
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