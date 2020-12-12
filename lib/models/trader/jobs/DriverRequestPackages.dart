class DriverRequestPackages {

  DriverRequest driverRequest;
  Driver driver;

  DriverRequestPackages({
    this.driverRequest,
    this.driver,
  });

  factory DriverRequestPackages.fromJson(Map<String, dynamic> parsedJson){
    return DriverRequestPackages(
      driverRequest : DriverRequest.fromJson(parsedJson["DriverRequest"]),
      driver : Driver.fromJson(parsedJson["Driver"]),
    );
  }
}
class DriverRequest {
  int DriverRequestID;
  int DriverID;
  int JobOfferID;
  String Price;
  String Created;

  DriverRequest({
    this.DriverRequestID,
    this.DriverID,
    this.JobOfferID,
    this.Price,
    this.Created,
  });
  factory DriverRequest.fromJson(Map<String, dynamic> parsedJson){
    return DriverRequest(
      DriverRequestID : parsedJson['DriverRequestID'],
      DriverID : parsedJson ['DriverID'],
      JobOfferID : parsedJson['JobOfferID'],
      Price : parsedJson ['Price'].toString(),
      Created : parsedJson ['Created'],
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