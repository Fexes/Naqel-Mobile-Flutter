
import 'package:naqelapp/models/driver/jobs/JobRequests.dart';



class TransportCompanyTrucks {

  int TruckID;
  String TruckNumber;
  String Brand;
  String Model;
  int DriverID;
  String PhotoURL;
  Driver driver;


  TransportCompanyTrucks({
    this.TruckID,
    this.Brand,
    this.Model,
    this.TruckNumber,
    this.DriverID,
    this.PhotoURL,
    this.driver,

  });

  factory TransportCompanyTrucks.fromJson(Map<String, dynamic> parsedJson){
    return TransportCompanyTrucks(
      TruckID: parsedJson['TruckID'],
      Brand : parsedJson['Brand'],
      Model : parsedJson ['Model'],
      TruckNumber : parsedJson['TruckNumber'],
      DriverID : parsedJson['DriverID'],
      PhotoURL :parsedJson['PhotoURL'],
      driver : Driver.fromJson(parsedJson["Driver"]),

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