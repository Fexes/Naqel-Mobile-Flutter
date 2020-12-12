

class TraderIdentityCard {


  int IdentityCardID;
  int TraderID;
  String IDNumber;
  String PhotoURL;
  String Created;

  TraderIdentityCard({
    this.IdentityCardID,
    this.TraderID,
    this.IDNumber,
    this.PhotoURL,
    this.Created,
  });

  factory TraderIdentityCard.fromJson(Map<String, dynamic> parsedJson){
    return TraderIdentityCard(
        IdentityCardID: parsedJson['IdentityCardID'],
        TraderID : parsedJson['TraderID'],
        IDNumber : parsedJson['IDNumber'],
        PhotoURL : parsedJson ['PhotoURL'],
        Created : parsedJson['Created']
    );
  }





}
