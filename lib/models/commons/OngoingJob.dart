
 

class OngoingJob {

  int CompletedByDriver;
  int CompletedByTrader;
  String Created;
  String JobNumber;
  int  DriverID;
  int OnGoingJobID;
  int TraderID;
  String LoadingPlace;
  String UnloadingPlace;
  String TripType;
  String Price;
  int WaitingTime;
  String TimeCreated;
  String CargoType;
  int CargoWeight;
  String LoadingLocation;
  String UnloadingLocation;
  String LoadingDate;
  String LoadingTime;
  String TruckModel;
  String DriverNationality;
  int EntryExit;
  int AcceptedDelay;
  String JobOfferType;
  Driver driver;
  Trader trader;

  double LoadingLat;
  double LoadingLng;
  double UnloadingLat;
  double UnloadingLng;

  OngoingJob({
    this.CompletedByDriver,
    this.CompletedByTrader,
    this.Created,
    this.DriverID,
    this.JobNumber,
    this.OnGoingJobID,
    this.TraderID,
    this.LoadingPlace,
    this.UnloadingPlace,
    this.TripType,
    this.Price,
    this.WaitingTime,
    this.TimeCreated,
    this. CargoType,
    this.CargoWeight,
    this. LoadingLocation,
    this. UnloadingLocation,
    this. LoadingDate,
    this. LoadingTime,
    this. TruckModel,
    this. DriverNationality,
    this.EntryExit,
    this.AcceptedDelay,
    this. JobOfferType,
    this.driver,
    this.trader,

    this.LoadingLat,
    this.LoadingLng,
    this.UnloadingLat,
    this.UnloadingLng,
  });

  factory OngoingJob.fromJson(Map<String, dynamic> parsedJson){
    return OngoingJob(
      LoadingLat: parsedJson['LoadingLat'],
      LoadingLng : parsedJson['LoadingLng'],
      UnloadingLat : parsedJson ['UnloadingLat'],
      UnloadingLng : parsedJson['UnloadingLng'],

      CompletedByDriver: parsedJson['CompletedByDriver'],
      CompletedByTrader : parsedJson['CompletedByTrader'],
      Created : parsedJson ['Created'],
      DriverID : parsedJson['DriverID'],
      JobNumber : parsedJson['JobNumber'],
      OnGoingJobID: parsedJson['OnGoingJobID'],
      TraderID : parsedJson['TraderID'],
      LoadingPlace : parsedJson ['LoadingPlace'],
      UnloadingPlace : parsedJson['UnloadingPlace'],
      TripType : parsedJson['TripType'],
      Price : parsedJson['Price'].toString(),
      WaitingTime : parsedJson['WaitingTime'],
      TimeCreated : parsedJson['TimeCreated'],
      CargoType: parsedJson['CargoType'],
      CargoWeight : parsedJson['CargoWeight'],
      LoadingLocation : parsedJson ['LoadingLocation'],
      UnloadingLocation : parsedJson['UnloadingLocation'],
      LoadingDate : parsedJson['LoadingDate'],
      LoadingTime : parsedJson['LoadingTime'],
      TruckModel : parsedJson['TruckModel'],
      DriverNationality : parsedJson['DriverNationality'],
      EntryExit : parsedJson['EntryExit'],
      AcceptedDelay : parsedJson['AcceptedDelay'],
      JobOfferType : parsedJson['JobOfferType'],
      driver : Driver.fromJson(parsedJson["Driver"]),
      trader : Trader.fromJson(parsedJson["Trader"]),


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