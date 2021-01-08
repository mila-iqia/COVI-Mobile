//
//  Ble.swift
//  Runner
//
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import CoreBluetooth
import Foundation

class Ble{
  static let shared = Ble(); // create singleton class
  
  public let NOTIFY_DESCRIPTOR_UUID: CBUUID = CBUUID(string : "00002902-0000-1000-8000-00805f9b34fb");
  public let SONAR_SERVICE_UUID: CBUUID = CBUUID(string : "6637c77b-7efd-4476-a4bf-f81d08cd67e4");
  public let SONAR_KEEPALIVE_CHARACTERISTIC_UUID: CBUUID = CBUUID(string : "D802C645-5C7B-40DD-985A-9FBEE05FE85C");
  public let SONAR_IDENTITY_CHARACTERISTIC_UUID : CBUUID = CBUUID(string : "85BF337C-5B64-48EB-A5F7-A9FED135C972");
  
  var DH_Key : [UInt8] = Array("".utf8);
  var receivedDHKeys : Array<[UInt8]> = [];
  
  private init(){}
  
  func isDeviceIdentifier(characteristic : CBUUID) -> Bool {
    return characteristic == SONAR_IDENTITY_CHARACTERISTIC_UUID;
  }
  
  func isNotifyDescriptor (characteristic : CBUUID) -> Bool {
    return characteristic == NOTIFY_DESCRIPTOR_UUID;
  }
  
  func getDHKey() -> [UInt8] {
    return DH_Key;
  }
  
  func getReceivedDHKeys() -> Array<[UInt8]> {
    return receivedDHKeys;
  }
  
  func setDH_Key(dhKey: [UInt8]) {
    DH_Key = dhKey;
  }
  
  func addToReceivedDHKeys(toAdd : [UInt8]) {
    if (!receivedDHKeys.contains(toAdd)) {
      receivedDHKeys.append(toAdd);
    }
  }
  
  func resetReceivedDHKeys() {
    receivedDHKeys = [];
  }
}
