

class EntryExitCard {


  int EntryExitCardID;
  int DriverID;
  String EntryExitNumber;
  String Type;
  String ReleaseDate;
  int NumberOfMonths;
 
  EntryExitCard({
    this.EntryExitCardID,
    this.DriverID,
    this.EntryExitNumber,
    this.Type,
    this.ReleaseDate,
    this.NumberOfMonths,

  });

  factory EntryExitCard.fromJson(Map<String, dynamic> parsedJson){
    return EntryExitCard(
        EntryExitCardID: parsedJson['EntryExitCardID'],
        EntryExitNumber : parsedJson['EntryExitNumber'],
        Type : parsedJson['Type'],
        ReleaseDate : parsedJson['ReleaseDate'],
        NumberOfMonths : parsedJson['NumberOfMonths']

    );
  }






}
