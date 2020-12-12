
import 'package:naqelapp/models/driver/jobs/JobRequests.dart';



class TransportCompanyResponsibleProfle {

  int TransportCompanyResponsibleID;
  String Email;
  String Username;
  String Password;
  String Name;
  String PhoneNumber;
  String InternalNumber;
  String CommercialRegisterNumber;
  int Active;
  String Created;




  TransportCompanyResponsibleProfle({
    this.TransportCompanyResponsibleID,
    this.Username,
    this.Password,
    this.PhoneNumber,
    this.Name,
    this.Email,
    this.InternalNumber,
    this.CommercialRegisterNumber,
    this.Active,
    this.Created,
  });

  factory TransportCompanyResponsibleProfle.fromJson(Map<String, dynamic> parsedJson){
    return TransportCompanyResponsibleProfle(
      TransportCompanyResponsibleID: parsedJson['TransportCompanyResponsibleID'],
      Username : parsedJson['Username'],
      Password : parsedJson ['Password'],
      PhoneNumber : parsedJson['PhoneNumber'],
      Name : parsedJson['Name'],
      Email : parsedJson['Email'],
      InternalNumber : parsedJson['InternalNumber'],
      CommercialRegisterNumber : parsedJson['CommercialRegisterNumber'],
      Active : parsedJson['Active'],
      Created : parsedJson['Created'],
    );
  }



}
