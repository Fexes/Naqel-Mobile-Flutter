
class JobOfferPackages {
  JobOfferTrader jobOfferTrader;
  bool HasDriverRequests;

  JobOfferPackages({
    this.jobOfferTrader,
    this.HasDriverRequests,

  });

  factory JobOfferPackages.fromJson(Map<String, dynamic> parsedJson){
    return JobOfferPackages(
      jobOfferTrader : JobOfferTrader.fromJson(parsedJson["JobOffer"]),
      HasDriverRequests : parsedJson["HasDriverRequests"],

    );
  }
}


class JobOfferTrader {


  int JobOfferID;
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
  int NumberOfDriverRequests;


  JobOfferTrader({
    this.JobOfferID,
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
    this.NumberOfDriverRequests,
  });

  factory JobOfferTrader.fromJson(Map<String, dynamic> parsedJson){
    return JobOfferTrader(
      JobOfferID: parsedJson['JobOfferID'],
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
      NumberOfDriverRequests : parsedJson['NumberOfDriverRequests'],


    );
  }


}