
class CompletedJobPackages{


  CompletedJob completedJob;
  DriverReview driverReview;


  CompletedJobPackages({
    this.completedJob,
    this.driverReview,
   });

  factory CompletedJobPackages.fromJson(Map<String, dynamic> parsedJson){
    return CompletedJobPackages(
      completedJob: CompletedJob.fromJson(parsedJson["CompletedJob"]),
      driverReview : DriverReview.fromJson(parsedJson["DriverReview"]),
     );
  }


}
class CompletedJob {
  int CompletedJobID;
  String JobNumber;
  int DriverID;
  int TraderID;
  String TripType;
  String CargoType;
  int CargoWeight;
  String LoadingPlace;
  String UnloadingPlace;
  String LoadingDate;
  String LoadingTime;
  int EntryExit;
  int AcceptedDelay;
  String Price;
  String Created;

  CompletedJob({
    this.CompletedJobID,
    this.JobNumber,
    this.DriverID,
    this.TraderID,
    this.TripType,
    this.CargoType,
    this.CargoWeight,
    this.LoadingPlace,
    this.UnloadingPlace,
    this.LoadingDate,
    this.LoadingTime,
    this.EntryExit,
    this.AcceptedDelay,
    this.Price,
     this.Created,
  });

  factory CompletedJob.fromJson(Map<String, dynamic> parsedJson){
    return CompletedJob(
      CompletedJobID: parsedJson['CompletedJobID'],
      JobNumber: parsedJson['JobNumber'],
      DriverID: parsedJson['DriverID'],
      TraderID: parsedJson['TraderID'],
      TripType: parsedJson['TripType'],
      CargoType: parsedJson['CargoType'],
      CargoWeight: parsedJson['CargoWeight'],
      LoadingPlace: parsedJson['LoadingPlace'],
      UnloadingPlace: parsedJson['UnloadingPlace'],
      LoadingDate: parsedJson['LoadingDate'],
      LoadingTime: parsedJson['LoadingTime'],
      EntryExit: parsedJson['EntryExit'],
      AcceptedDelay: parsedJson['AcceptedDelay'],
      Price: parsedJson['Price'].toString(),
      Created:parsedJson['Created'],

    );
  }



}
class DriverReview {
  int DriverReviewID;
  int CompletedJobID;
  int DriverID;
  int TraderID;
  String Review;
  int Rating;
  String Created;

  DriverReview({
    this.DriverReviewID,
    this.CompletedJobID,
    this.DriverID,
    this.TraderID,
    this.Review,
    this.Rating,
    this.Created,
  });

  factory DriverReview.fromJson(Map<String, dynamic> parsedJson){
    if(parsedJson!=null) {
      return DriverReview(
        DriverReviewID: parsedJson['DriverReviewID'],
        CompletedJobID: parsedJson['CompletedJobID'],
        DriverID: parsedJson['DriverID'],
        TraderID: parsedJson['TraderID'],
        Review: parsedJson['Review'],
        Rating: parsedJson['Rating'],
        Created: parsedJson['Created'],

      );
    }else{
      return null;
    }
  }

}



