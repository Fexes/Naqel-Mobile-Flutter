class JobRequests {

  int JobRequestID;
  int DriverID;
  String LoadingPlace;
  String UnloadingPlace;
  String TripType;
  String Price;
  int WaitingTime;
  String TimeCreated;
  int NumberOfTraderRequests;

  JobRequests({
    this.JobRequestID,
    this.DriverID,
    this.LoadingPlace,
    this.UnloadingPlace,
    this.TripType,
    this.Price,
    this.WaitingTime,
    this.TimeCreated,
    this.NumberOfTraderRequests,
  });

  factory JobRequests.fromJson(Map<String, dynamic> parsedJson){
    return JobRequests(
        JobRequestID: parsedJson['JobRequestID'],
        DriverID : parsedJson['DriverID'],
        LoadingPlace : parsedJson ['LoadingPlace'],
        UnloadingPlace : parsedJson['UnloadingPlace'],
        TripType : parsedJson['TripType'],
        Price : parsedJson['Price'].toString(),
        WaitingTime : parsedJson['WaitingTime'],
        TimeCreated : parsedJson['TimeCreated'],
        NumberOfTraderRequests : parsedJson['NumberOfTraderRequests'],

    );
  }


}