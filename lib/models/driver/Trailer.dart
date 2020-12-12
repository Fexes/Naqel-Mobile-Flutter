

class Trailer {


  int TrailerID;
  int TruckID;
  int MaximumWeight;
  String PhotoURL;
  String Type;

  Trailer({
    this.TrailerID,
    this.TruckID,
    this.MaximumWeight,
    this.PhotoURL,
    this.Type
  });

  factory Trailer.fromJson(Map<String, dynamic> parsedJson){
    return Trailer(
        TrailerID: parsedJson['TrailerID'],
        MaximumWeight : parsedJson['MaximumWeight'],
        PhotoURL : parsedJson ['PhotoURL'],
        Type : parsedJson['Type']
    );
  }





}
