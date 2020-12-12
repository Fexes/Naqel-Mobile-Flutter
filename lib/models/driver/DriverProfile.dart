
import 'package:naqelapp/models/driver/jobs/JobRequests.dart';



class DriverProfile {

   int DriverID;
   String Username;
   String Password;
   String PhoneNumber;
   String FirstName;
   String LastName;
   String Nationality;
   String Email;
   String Gender;
   String DateOfBirth;
   String Address;
   String PhotoURL;
   int    Active;
   bool   IsComplete;



  DriverProfile({
    this.DriverID,
    this.Username,
    this.Password,
    this.PhoneNumber,
    this.FirstName,
    this.LastName,
    this.Nationality,
    this.Email,
    this.Gender,
    this.DateOfBirth,
    this.Address,
    this.PhotoURL,
    this.Active,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> parsedJson){
    return DriverProfile(
        DriverID: parsedJson['DriverID'],
        Username : parsedJson['Username'],
        Password : parsedJson ['Password'],
        PhoneNumber : parsedJson['PhoneNumber'],
        FirstName : parsedJson['FirstName'],
        LastName : parsedJson['LastName'],
        Nationality : parsedJson['Nationality'],
        Email : parsedJson['Email'],
        Gender : parsedJson['Gender'],
        DateOfBirth : parsedJson['DateOfBirth'],
        Address : parsedJson['Address'],
        PhotoURL : parsedJson['PhotoURL'],
        Active : parsedJson['Active'],
    );
  }



}
