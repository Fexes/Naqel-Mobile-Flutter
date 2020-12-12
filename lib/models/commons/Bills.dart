
class Bills {
  int TraderBillID;
  int DriverID;
  int TraderID;
  int CompletedJobID;
  int Amount;
  int Paid;
  String BillNumber;
  int FeeRate;
  String Created;
  String JobNumber;
  SpecialTraderBill specialTraderBill;
  bool HasPayProof;
  bool HasPayDetails;


  Bills({
    this.TraderBillID,
    this.DriverID,
    this.TraderID,
    this.CompletedJobID,
    this.Amount,
    this.Paid,
    this.BillNumber,
    this.FeeRate,
    this.Created,
    this.JobNumber,
    this.specialTraderBill,
    this.HasPayProof,
    this.HasPayDetails,


  });
  factory Bills.fromJson(Map<String, dynamic> parsedJson){
    return Bills(
      TraderBillID : parsedJson['TraderBillID'],
      DriverID : parsedJson['DriverID'],
      TraderID : parsedJson['TraderID'],
      CompletedJobID : parsedJson['CompletedJobID'],
      Amount : parsedJson['Amount'],
      Paid : parsedJson['Paid'],
      BillNumber : parsedJson['BillNumber'],
      FeeRate : parsedJson['FeeRate'],
      Created : parsedJson['Created'],
      JobNumber : parsedJson['JobNumber'],
       HasPayProof : parsedJson['HasPayProof'],
      HasPayDetails : parsedJson['HasPayDetails'],
      //specialTraderBill : SpecialTraderBill.fromJson(parsedJson["Bills"]),



    );
  }
}

class SpecialTraderBill {
  int SpecialTraderBillID;
  int TraderBillID;
  double Amount;




  SpecialTraderBill({
    this.SpecialTraderBillID,
    this.TraderBillID,
    this.Amount,



  });
  factory SpecialTraderBill.fromJson(Map<String, dynamic> parsedJson){
    return SpecialTraderBill(
      TraderBillID : parsedJson['TraderBillID'],
      SpecialTraderBillID : parsedJson['SpecialTraderBillID'],
      Amount : parsedJson['Amount'],

    );
  }
}