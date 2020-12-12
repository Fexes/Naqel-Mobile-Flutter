

class DrivingLicence {


  int DrivingLicenceID;
  int DriverID;
  String LicenceNumber;
  String PhotoURL;
  String Type;
  String ReleaseDate;
  String ExpiryDate;
  String Created;

  DrivingLicence({
    this.DrivingLicenceID,
    this.DriverID,
    this.LicenceNumber,
    this.PhotoURL,
    this.Type,
    this.ReleaseDate,
    this.ExpiryDate,
    this.Created

  });

  factory DrivingLicence.fromJson(Map<String, dynamic> parsedJson){
    return DrivingLicence(
        DrivingLicenceID: parsedJson['DrivingLicenceID'],
        LicenceNumber : parsedJson['LicenceNumber'],
        PhotoURL : parsedJson ['PhotoURL'],
        Type : parsedJson['Type'],
        ReleaseDate : parsedJson['ReleaseDate'],
        ExpiryDate : parsedJson['ExpiryDate'],
        Created : parsedJson['Created']

    );
  }






}
