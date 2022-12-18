import UIKit
import Flutter
import GoogleMaps
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBC0Waje9kAnLXpGRm5odsPWgXW_5t59sk")
    GeneratedPluginRegistrant.register(with: self)
    let nativeAdFactory = NativeAdFactoryExample()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "adFactoryExample", nativeAdFactory: nativeAdFactory)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

