

class CommercialRegisterCertificate {


  int ID;
  int TraderID;
  String Number;
  String Type;
  String PhotoURL;
 
  CommercialRegisterCertificate({
    this.ID,
    this.TraderID,
    this.Number,
    this.Type,
    this.PhotoURL,

  });

  factory CommercialRegisterCertificate.fromJson(Map<String, dynamic> parsedJson){
    return CommercialRegisterCertificate(
        ID: parsedJson['ID'],
        Number : parsedJson['Number'],
        Type : parsedJson['Type'],
        PhotoURL : parsedJson['PhotoURL'],

    );
  }






}
