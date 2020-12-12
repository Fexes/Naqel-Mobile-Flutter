

class URLs{

  static String BaseURL = "https://naqelserver.azurewebsites.net/";

///************** Driver Auth *************/

  static String loginUrl(){
    return "$BaseURL/drivers/login";
  }
  static String getDriverUrl(){
    return "$BaseURL/drivers/getDriver";
  }
  static String registercheckUrl(){
    return "$BaseURL/drivers/register";
  }
  static String signUpUrl(){
    return "$BaseURL/users/accountSetup";
  }
  static String generalSettingUrl(){
    return "$BaseURL/drivers/generalSettings";
  }
  static String emailSettingUrl(){
    return "$BaseURL/drivers/usernameAndEmailSettings";
  }
  static String passwordSettingUrl(){
    return "$BaseURL/drivers/passwordSettings";
  }
  static String updatePhotoUrlInDatabase(){
    return "$BaseURL/drivers/uploadDriverProfilePhoto";
  }
  ///************** Trader Auth *************/


  static String traderLoginUrl(){
    return "$BaseURL/traders/login";
  }
  static String getTraderUrl(){
    return "$BaseURL/traders/getTrader";
  }
  static String uploadTraderProfilePhotoUrl(){
    return "$BaseURL/traders/uploadTraderProfilePhoto";
  }
  static String tradergeneralSettingsUrl(){
    return "$BaseURL/traders/generalSettings";
  }

  static String traderpasswordSettingsSettingsUrl(){
    return "$BaseURL/traders/passwordSettings";
  }
  static String traderusernameAndEmailSettingsUrl(){
    return "$BaseURL/traders/usernameAndEmailSettings";
  }

  static String tradergetIdentityCardUrl(){
    return "$BaseURL/traders/getIdentityCard";
  }

  static String traderaddIdentityCardUrl(){
    return "$BaseURL/traders/addIdentityCard";
  }

  static String traderdeleteIdentityCardUrl(){
    return "$BaseURL/traders/deleteIdentityCard";
  }
  static String getCommercialRegisterCertificateUrl(){
    return "$BaseURL/traders/getCommercialRegisterCertificate";
  }

  static String addCommercialRegisterCertificateUrl(){
    return "$BaseURL/traders/addCommercialRegisterCertificate";
  }
  ///************** Trucks *************/

  static String getTruckUrl(){
    return "$BaseURL/drivers/getTruck";
  }
  static String addTruckUrl(){
    return "$BaseURL/drivers/addTruck";
  }
  static String updateTruckUrl(){
    return "$BaseURL/drivers/updateTruck";
  }
  static String updateTruckPhotoUrlInDatabase(){
    return "$BaseURL/drivers/updateTruckPhoto";
  }

  /// ************ Trailers *************/

  static String getTrailersUrl(){
    return "$BaseURL/drivers/getTrailers";
  }
  static String addTrailerURl(){
    return "$BaseURL/drivers/addTrailer";
  }
  static String deleteTrailerURL(){
    return "$BaseURL/drivers/deleteTrailer";
  }

///************** Permits *************/

  static String getPermitLicences(){
    return "$BaseURL/drivers/getPermitLicences";
  }
  static String addPermitsURl(){
    return "$BaseURL/drivers/addPermitLicence";
  }
  static String deletePermitURL(){
    return "$BaseURL/drivers/deletePermitLicence";
  }

  ///************** Documents *************/

  static String getDrivingLicenceURL(){
    return "$BaseURL/drivers/getDrivingLicence";
  }
  static String getEntryExitCardURL(){
    return "$BaseURL/drivers/getEntryExitCard";
  }
  static String getIdentityCardURL(){
    return "$BaseURL/drivers/getIdentityCard";
  }


  static String deleteDrivingLicenceURL(){
    return "$BaseURL/drivers/deleteDrivingLicence";
  }
  static String deleteEntryExitCardURL(){
    return "$BaseURL/drivers/deleteEntryExitCard";
  }
  static String deleteIdentityCardURL(){
    return "$BaseURL/drivers/deleteIdentityCard";
  }



  static String addDrivingLicenceURL(){
    return "$BaseURL/drivers/addDrivingLicence";
  }

  static String addIdentityCardURL(){
    return "$BaseURL/drivers/addIdentityCard";
  }
  ///************** Job Requests *************/

  static String getJobRequestPackagesURL(){
    return "$BaseURL/drivers/getJobRequestPackages";
  }
  static String deleteDriverRequestURL(){
    return "$BaseURL/drivers/deleteJobRequest";
  }

  static String deleteTraderJobofferURL(){
    return "$BaseURL/traders/deleteJobOffer";
  }
  static String getTraderRequestPackagesURL(){
    return "$BaseURL/drivers/getTraderRequestPackages";
  }

  static String getDriverRequestPackagesURL(){
    return "$BaseURL/traders/getDriverRequestPackages";
  }

  static String getJobRequestPostsURL(){
    return "$BaseURL/traders/getJobRequestPosts";
  }
  static String toggleSelectTraderRequestURL(){
    return "$BaseURL/drivers/toggleSelectTraderRequest";
  }



  static String addTraderRequestsURL(){
    return "$BaseURL/traders/addTraderRequest";
  }

  static String addOnGoingJobFromJobRequestURL(){
    return "$BaseURL/traders/addOnGoingJobFromJobRequest";
  }
  static String addOnGoingJobFromJobOfferURL(){
    return "$BaseURL/traders/addOnGoingJobFromJobOffer";
  }


  ///************** Job Offers *************/

  static String getJobOfferPostsURL(){
    return "$BaseURL/drivers/getJobOfferPosts";
  }
  static String getTraderJobOfferPostsURL(){
    return "$BaseURL/traders/getJobOfferPackages";
  }
  static String addDriverRequestURL(){
    return "$BaseURL/drivers/addDriverRequest";
  }
  static String deleteDriverRequestoffferURL(){
    return "$BaseURL/drivers/deleteDriverRequest";
  }


///************** Completed Jobs *************/

  static String getCompletedJobPackagesURL(){
    return "$BaseURL/drivers/getCompletedJobPackages";
  }
  static String tradergetCompletedJobPackagesURL(){
    return "$BaseURL/traders/getCompletedJobPackages";
  }

  static String addJobRequestURL(){
    return "$BaseURL/drivers/addJobRequest";
  }
  ///************** On Going Jobs *************/

  static String getOnGoingJobURL(){
    return "$BaseURL/drivers/getOnGoingJob";
  }
  static String gettradersOnGoingJobURL(){
    return "$BaseURL/traders/getOnGoingJob";
  }
  static String driverfinishJobURL(){
    return "$BaseURL/drivers/finishJob";
  }
  static String traderapproveJobJobURL(){
    return "$BaseURL/traders/approveJob";
  }

///************** Questions *************/

static String drivergetQuestionsURL(){
    return "$BaseURL/drivers/getQuestions";
  }
  static String driverdeleteQuestionURL(){
    return "$BaseURL/drivers/deleteQuestion";
  }
  static String driveraddQuestionURL(){
    return "$BaseURL/drivers/addQuestion";
  }

  static String tradersgetQuestionsURL(){
    return "$BaseURL/traders/getQuestions";
  }
  static String tradersdeleteQuestionURL(){
    return "$BaseURL/traders/deleteQuestion";
  }
  static String tradersaddQuestionURL(){
    return "$BaseURL/traders/addQuestion";
  }
  static String addDriverReviewURL(){
    return "$BaseURL/traders/addDriverReview";
  }
  static String addJobOfferURL(){
    return "$BaseURL/traders/addJobOffer";
  }






  static String gettransportCompanyResponsiblesURL(){
    return "$BaseURL/transportCompanyResponsibles/getYransportCompanyResponsibles";
  }

  static String getTraderProfileURL(){
    return "$BaseURL/users/getTraderProfile";
  }

  static String getDriverProfileURL(){
    return "$BaseURL/users/getDriverProfile";
  }

  static String getJobObjectionPackagesURL(){
    return "$BaseURL/drivers/getJobObjections";
  }



  static String transportCompanyResponsiblesLoginURL(){
    return "$BaseURL/transportCompanyResponsibles/login";
  }
  static String getTransportCompanyResponsibleURL(){
    return "$BaseURL/transportCompanyResponsibles/getTransportCompanyResponsible";
  }

  static String getTransportCompanyResponsiblegetQuestionsURL(){
    return "$BaseURL/transportCompanyResponsibles/getQuestions";
  }
  static String getTransportCompanyResponsibleaddQuestionURL(){
    return "$BaseURL/transportCompanyResponsibles/addQuestion";
  }
  static String getTransportCompanyResponsibleadeleteQuestionURL(){
    return "$BaseURL/transportCompanyResponsibles/deleteQuestion";
  }

  static String getTransportCompanyResponsiblegetTrucksURL(){
    return "$BaseURL/transportCompanyResponsibles/getTrucks";
  }

  static String getTraderBillsURL(){
    return "$BaseURL/traders/getBills";
  }
  static String getTraderBillDataURL(){
    return "$BaseURL/traders/getBillData";
  }

  static String getUserTruckSizesURL(){
    return "$BaseURL/users/getTruckSizes";
  }
  static String getUserTruckTypesURL(){
    return "$BaseURL/users/getTruckTypes";
  }
  static String getUserWaitingTimeURL(){
    return "$BaseURL/users/getWaitingTimes";
  }
  static String getUserPermitTypesURL(){
    return "$BaseURL/users/getPermitTypes";
  }

 }
