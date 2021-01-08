//
//  BTLEListener.swift
//  Runner
//
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import CoreBluetooth
import CommonCrypto
import Logging

protocol BTLEPeripheral {
  var identifier: UUID { get }
}

extension CBPeripheral: BTLEPeripheral {
}

protocol BTLEListenerDelegate {
  func btleListener(_ listener: BTLEListener, didFind broadcastPayload: IncomingBroadcastPayload, for peripheral: BTLEPeripheral)
  func btleListener(_ listener: BTLEListener, didReadRSSI RSSI: Int, for peripheral: BTLEPeripheral)
  func btleListener(_ listener: BTLEListener, didReadTxPower txPower: Int, for peripheral: BTLEPeripheral)
}

protocol BTLEListenerStateDelegate {
  func btleListener(_ listener: BTLEListener, didUpdateState state: CBManagerState)
}

protocol BTLEListener {
  func start(stateDelegate: BTLEListenerStateDelegate?, delegate: BTLEListenerDelegate?)
  func isHealthy() -> Bool
}

class ConcreteBTLEListener: NSObject, BTLEListener, CBCentralManagerDelegate, CBPeripheralDelegate {
  
  var broadcaster: BTLEBroadcaster
  var stateDelegate: BTLEListenerStateDelegate?
  var delegate: BTLEListenerDelegate?
  
  var peripherals: [UUID: CBPeripheral] = [:]
  
  // comfortably less than the ~10s background processing time Core Bluetooth gives us when it wakes us up
  private let keepaliveInterval: TimeInterval = 8.0
  
  private var lastKeepaliveDate: Date = Date.distantPast
  private var keepaliveValue: UInt8 = 0
  private var keepaliveTimer: DispatchSourceTimer?
  private let dateFormatter = ISO8601DateFormatter()
  private let queue: DispatchQueue
  
  init(broadcaster: BTLEBroadcaster, queue: DispatchQueue) {
    self.broadcaster = broadcaster
    self.queue = queue
  }
  
  func start(stateDelegate: BTLEListenerStateDelegate?, delegate: BTLEListenerDelegate?) {
    self.stateDelegate = stateDelegate
    self.delegate = delegate
  }
  
  
  // MARK: CBCentralManagerDelegate
  
  func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    if let restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
      logger.info("restoring \(restoredPeripherals.count) \(restoredPeripherals.count == 1 ? "peripheral" : "peripherals") for central \(central)")
      for peripheral in restoredPeripherals {
        peripherals[peripheral.identifier] = peripheral
        peripheral.delegate = self
      }
    } else {
      logger.info("no peripherals to restore for \(central)")
    }
    
    if let restoredScanningServices = dict[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID] {
      logger.info("restoring scanning for \(restoredScanningServices.count) \(restoredScanningServices.count == 1 ? "service" : "services") for central \(central)")
      for restoredScanningService in restoredScanningServices {
        logger.info("    service \(restoredScanningService.uuidString)")
      }
    } else {
      logger.info("no scanning restored for \(central)")
    }
    
    if let scanOptions = dict[CBCentralManagerRestoredStateScanOptionsKey] as? Dictionary<String, Any> {
      logger.info("restoring \(scanOptions.count) \(scanOptions.count == 1 ? "scanOption" : "scanOptions") for central \(central)")
      for scanOption in scanOptions {
        logger.info("    scanOption: \(scanOption.key), value: \(scanOption.value)")
      }
    } else {
      logger.info("no scanOptions restored for \(central)")
    }
    logger.info("central \(central.isScanning ? "is" : "is not") scanning")
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    logger.info("state: \(central.state)")
    
    stateDelegate?.btleListener(self, didUpdateState: central.state)
    
    switch (central.state) {
      
    case .poweredOn:
      
      // Reconnect to all the peripherals we found in willRestoreState (assume calling connect is idempotent)
      for peripheral in peripherals.values {
        central.connect(peripheral)
      }
      
      central.scanForPeripherals(withServices: [Ble.shared.SONAR_SERVICE_UUID])
      
    default:
      break
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    if let txPower = (advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue {
      logger.info("peripheral \(peripheral.identifierWithName) discovered with RSSI = \(RSSI), txPower = \(txPower)")
      delegate?.btleListener(self, didReadTxPower: txPower, for: peripheral)
    } else {
      logger.info("peripheral \(peripheral.identifierWithName) discovered with RSSI = \(RSSI)")
    }
    
    if peripherals[peripheral.identifier] == nil || peripherals[peripheral.identifier]!.state != .connected {
      peripherals[peripheral.identifier] = peripheral
      central.connect(peripheral)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    logger.info("\(peripheral.identifierWithName)")
    
    peripheral.delegate = self
    peripheral.readRSSI()
    peripheral.discoverServices([Ble.shared.SONAR_SERVICE_UUID])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if let error = error {
      logger.info("attempting reconnection to \(peripheral.identifierWithName) after error: \(error)")
    } else {
      logger.info("attempting reconnection to \(peripheral.identifierWithName)")
    }
    central.connect(peripheral)
  }
  
  // MARK: CBPeripheralDelegate
  
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    logger.info("\(peripheral.identifierWithName) invalidatedServices:")
    for service in invalidatedServices {
      logger.info("\t\(service)\n")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard error == nil else {
      logger.info("periperhal \(peripheral.identifierWithName) error: \(error!)")
      return
    }
    
    guard let services = peripheral.services, services.count > 0 else {
      logger.info("No services discovered for peripheral \(peripheral.identifierWithName)")
      return
    }
    
    guard let sonarIdService = services.sonarIdService() else {
      logger.info("sonarId service not discovered for \(peripheral.identifierWithName)")
      return
    }
    
    logger.info("discovering characteristics for peripheral \(peripheral.identifierWithName) with sonarId service \(sonarIdService)")
    let characteristics = [
      Ble.shared.SONAR_IDENTITY_CHARACTERISTIC_UUID,
    ]
    peripheral.discoverCharacteristics(characteristics, for: sonarIdService)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard error == nil else {
      logger.info("periperhal \(peripheral.identifierWithName) error: \(error!)")
      return
    }
    
    guard let characteristics = service.characteristics, characteristics.count > 0 else {
      logger.info("no characteristics discovered for service \(service)")
      return
    }
    logger.info("\(characteristics.count) \(characteristics.count == 1 ? "characteristic" : "characteristics") discovered for service \(service): \(characteristics)")
    
    if let sonarIdCharacteristic = characteristics.sonarIdCharacteristic() {
      logger.info("reading sonarId from sonarId characteristic \(sonarIdCharacteristic)")
      peripheral.readValue(for: sonarIdCharacteristic)
      peripheral.setNotifyValue(true, for: sonarIdCharacteristic)
    } else {
      logger.info("sonarId characteristic not discovered for peripheral \(peripheral.identifierWithName)")
    }
    
    if let keepaliveCharacteristic = characteristics.keepaliveCharacteristic() {
      logger.info("subscribing to keepalive characteristic \(keepaliveCharacteristic)")
      peripheral.setNotifyValue(true, for: keepaliveCharacteristic)
    } else {
      logger.info("keepalive characteristic not discovered for peripheral \(peripheral.identifierWithName)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      logger.info("characteristic \(characteristic) error: \(error!)")
      return
    }
    
    switch characteristic.value {
      
    case (let data?) where characteristic.uuid == Ble.shared.SONAR_IDENTITY_CHARACTERISTIC_UUID:
      logger.info("read identity from peripheral \(peripheral.identifierWithName): \(data)")
      delegate?.btleListener(self, didFind: IncomingBroadcastPayload(data: data), for: peripheral)
      
      if data.count == 32 {
        logger.info("read identity from peripheral \(peripheral.identifierWithName): \(data)")
        dump(data);
        Ble.shared.addToReceivedDHKeys(toAdd: [UInt8](data))
      } else {
        logger.info("no identity ready from peripheral \(peripheral.identifierWithName)")
      }
      
      peripheral.readRSSI()
      
    case .none:
      logger.info("characteristic \(characteristic) has no data")
      
    default:
      logger.info("characteristic \(characteristic) has unknown uuid \(characteristic.uuid)")
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    guard error == nil else {
      logger.info("error: \(error!)")
      return
    }
  }
  
  func isHealthy() -> Bool {
    guard keepaliveTimer != nil else { return false }
    guard stateDelegate != nil else { return false }
    guard delegate != nil else { return false }
    
    return true
  }
  
  fileprivate let logger = Logger(label: "BTLE")
}
