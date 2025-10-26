import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Canal para obtener la zona horaria del dispositivo
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.fynso/timezone",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
      if call.method == "getTimeZoneName" {
        result(TimeZone.current.identifier) // ej. "America/Lima"
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
