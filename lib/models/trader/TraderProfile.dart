
import 'package:naqelapp/models/driver/jobs/JobRequests.dart';



class TraderProfile {

  int TraderID;
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
  String BankName;
  String IBAN;

  TraderProfile({
    this.TraderID,
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
    this.BankName,
    this.IBAN,
  });

  factory TraderProfile.fromJson(Map<String, dynamic> parsedJson){
    return TraderProfile(
      TraderID: parsedJson['TraderID'],
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
      BankName : parsedJson['BankName'],
      IBAN : parsedJson['IBAN'],

    );
  }



}
