import UIKit
import Flutter
import GoogleMaps
import Firebase;

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices .provideAPIKey("AIzaSyDezgtwvxs_HZGG8Dlkbt4Bi4IGymlvUnM")
    

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
