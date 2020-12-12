

import 'Trailer.dart';

class Trucks {


   int DriverID;
   int TruckID;
   int TransportCompanyID;
   String PlateNumber;
   String Owner;
   int ProductionYear;
   String Brand;
   String Model;
   String Type;
   int MaximumWeight;
   String PhotoURL;



  Trucks({
    this.DriverID,
    this.TruckID,
    this.TransportCompanyID,
    this.PlateNumber,
    this.Owner,
    this.ProductionYear,
    this.Brand,
    this.Model,
    this.Type,
    this.MaximumWeight,
    this.PhotoURL,
  });

  factory Trucks.fromJson(Map<String, dynamic> parsedJson){
    return Trucks(
      DriverID: parsedJson['DriverID'],
      TruckID : parsedJson['TruckID'],
      TransportCompanyID : parsedJson ['TransportCompanyID'],
      PlateNumber : parsedJson['PlateNumber'],
      Owner : parsedJson['Owner'],
      ProductionYear : parsedJson['ProductionYear'],
      Brand : parsedJson['Brand'],
      Model : parsedJson['Model'],
      Type : parsedJson['Type'],
      MaximumWeight : parsedJson['MaximumWeight'],
      PhotoURL : parsedJson['PhotoURL'],
    );
  }

 
}
