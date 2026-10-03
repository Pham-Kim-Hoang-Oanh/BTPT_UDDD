
import UIKit
import GoogleMaps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate { 
override func application( 
_ application: UIApplication, 
didFinishLaunchingWithOptions launchOptions: 
[UIApplication.LaunchOptionsKey: Any]? 
) -> Bool { 
GMSServices.provideAPIKey("AIzaSyAvNHVKVvV9LwKpoXv2DkcBYGpxhI5pPBM") // Thay bằng API Key 
return super.application(application, didFinishLaunchingWithOptions: 
launchOptions) 
} 
}
