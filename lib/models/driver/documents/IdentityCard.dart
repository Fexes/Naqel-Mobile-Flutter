

class IdentityCard {


  int IdentityCardID;
  int DriverID;
  String IDNumber;
  String PhotoURL;
  String Created;

  IdentityCard({
    this.IdentityCardID,
    this.DriverID,
    this.IDNumber,
    this.PhotoURL,
    this.Created,
  });

  factory IdentityCard.fromJson(Map<String, dynamic> parsedJson){
    return IdentityCard(
        IdentityCardID: parsedJson['IdentityCardID'],
        DriverID : parsedJson['DriverID'],
        IDNumber : parsedJson['IDNumber'],
        PhotoURL : parsedJson ['PhotoURL'],
        Created : parsedJson['Created']
    );
  }





}
