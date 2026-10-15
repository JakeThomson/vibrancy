import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // The parity scripts (tools/parity) configure the app through its launch
    // environment, which Dart cannot read on iOS; hand over the VIB_*
    // variables.
    let messenger = engineBridge.applicationRegistrar.messenger()
    let channel = FlutterMethodChannel(name: "vibrancy.example/parity", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "environment" else { return result(FlutterMethodNotImplemented) }
      result(ProcessInfo.processInfo.environment.filter { $0.key.hasPrefix("VIB_") })
    }
  }
}
