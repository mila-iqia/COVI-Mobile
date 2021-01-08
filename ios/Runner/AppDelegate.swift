import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let notificationCenter = NotificationCenter.default
  let authManager: AuthorizationManager = AuthorizationManager()
  let KEYCHAIN_SERVICE_NAME: String = "flutter_secure_storage_service"
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let bluetoothChannel = FlutterMethodChannel(name: "com.covi.app/ble", binaryMessenger: controller.binaryMessenger)
    
    bluetoothChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Include test methode to check which plateform is running
      // Method handler for BLE Monitoring
      switch call.method {
      case "start_bluetooth_service" :
        // todo : start bluetooth service
        controller.instanciateBluetoothNursery()
        logger.info("Instanciated Bluetooth Nursery")
        controller.startBluetoothNursery()
        logger.info("Started Bluetooth")
        result(nil);
      case "change_dh_key" :
        let myFlutterData: FlutterStandardTypedData = call.arguments as! FlutterStandardTypedData
        let myData : [UInt8] = Array(myFlutterData.data)
        Ble.shared.setDH_Key(dhKey: myData)
      case "get_received_dh_keys" :
        // uint8 are fkytterStabdardTypedData in flutter. Cast them this way before sending it back to flutter.
        var flutterTypedKeys : Array<FlutterStandardTypedData> = []
        let receivedDHKeys : Array<[UInt8]> = Ble.shared.getReceivedDHKeys()
        
        for dhKey in receivedDHKeys {
          let flutterUint8DhKey : FlutterStandardTypedData = FlutterStandardTypedData(bytes: Data(dhKey))
          flutterTypedKeys.append(flutterUint8DhKey)
        }
        Ble.shared.resetReceivedDHKeys()
        result(flutterTypedKeys)
      case "bluetooth_exists" :
        result(true)
      default:
        result("error")
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - Logging
private let logger = Logger(label: "AppDelegate")
