//
//  BluetoothNursery.swift
//  Runner
//
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreBluetooth
import Logging

protocol BluetoothNursery {
  func startBluetooth()
  var hasStarted: Bool { get }
}

class ConcreteBluetoothNursery: BluetoothNursery {
  static let centralRestoreIdentifier: String = "SonarCentralRestoreIdentifier"
  static let peripheralRestoreIdentifier: String = "SonarPeripheralRestoreIdentifier"

  private let btleQueue: DispatchQueue = DispatchQueue(label: "BTLE Queue")
  
  // The listener needs to get hold of the broadcaster, to send keepalives
  public var broadcaster: BTLEBroadcaster?
  
  public var listener: BTLEListener?
  public private(set) var stateObserver: BluetoothStateObserving = BluetoothStateObserver(initialState: .unknown)
  
  private var central: CBCentralManager?
  private var peripheral: CBPeripheralManager?
  
  func startBluetooth() {
    logger.info("Starting the bluetooth nursery")
    
    let broadcaster = ConcreteBTLEBroadcaster()
    peripheral = CBPeripheralManager(delegate: broadcaster, queue: btleQueue, options: [
      CBPeripheralManagerOptionRestoreIdentifierKey: ConcreteBluetoothNursery.peripheralRestoreIdentifier
    ])
    self.broadcaster = broadcaster
    
    let listener = ConcreteBTLEListener(broadcaster: broadcaster, queue: btleQueue)
    central = CBCentralManager(delegate: listener, queue: btleQueue, options: [
      CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(true),
      CBCentralManagerOptionRestoreIdentifierKey: ConcreteBluetoothNursery.centralRestoreIdentifier,
      CBCentralManagerOptionShowPowerAlertKey: NSNumber(true),
    ])
    
    listener.stateDelegate = self.stateObserver
    
    self.listener = listener
  }
  
  var hasStarted: Bool { return self.listener != nil } 
}

// MARK: - Logging
private let logger = Logger(label: "BTLE")
