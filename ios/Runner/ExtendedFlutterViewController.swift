//
//  ExtendedFlutterViewController.swift
//  Runner
//
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreBluetooth

struct AssociatedKeys {
  static var bluetoothNursery: BluetoothNursery? = nil
  static var serviceUUID: CBUUID? = nil
  static var keepaliveCharacteristicUUID: CBUUID? = nil
  static var characteristicUUID: CBUUID? = nil
}

extension FlutterViewController {
  private(set) var bluetoothNursery: BluetoothNursery? {
      get {
          guard let value = objc_getAssociatedObject(self, &AssociatedKeys.bluetoothNursery) as? BluetoothNursery else {
              return nil
          }
          return value
      }
      set(newValue) {
          objc_setAssociatedObject(self, &AssociatedKeys.bluetoothNursery, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
  }
  
//  private(set) var serviceUUID: CBUUID? {
//      get {
//          guard let value = objc_getAssociatedObject(self, &AssociatedKeys.serviceUUID) as? CBUUID else {
//              return nil
//          }
//          return value
//      }
//      set(newValue) {
//          objc_setAssociatedObject(self, &AssociatedKeys.serviceUUID, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//      }
//  }
//  
//  private(set) var keepaliveCharacteristicUUID: CBUUID? {
//      get {
//          guard let value = objc_getAssociatedObject(self, &AssociatedKeys.keepaliveCharacteristicUUID) as? CBUUID else {
//              return nil
//          }
//          return value
//      }
//      set(newValue) {
//          objc_setAssociatedObject(self, &AssociatedKeys.keepaliveCharacteristicUUID, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//      }
//  }
//  
//  private(set) var characteristicUUID: CBUUID? {
//      get {
//          guard let value = objc_getAssociatedObject(self, &AssociatedKeys.characteristicUUID) as? CBUUID else {
//              return nil
//          }
//          return value
//      }
//      set(newValue) {
//          objc_setAssociatedObject(self, &AssociatedKeys.characteristicUUID, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//      }
//  }
  
  func instanciateBluetoothNursery() {
    self.bluetoothNursery = ConcreteBluetoothNursery()
  }
  
  func startBluetoothNursery() {
    self.bluetoothNursery?.startBluetooth()
  }

//  func setServiceUUID(serviceUUID: CBUUID) {
//    self.serviceUUID = serviceUUID
//  }
//
//  func setKeepaliveCharacteristicUUID(keepaliveCharacteristicUUID: CBUUID) {
//    self.keepaliveCharacteristicUUID = keepaliveCharacteristicUUID
//  }0
//  func setCharacteristicUUID(characteristicUUID: CBUUID) {
//    self.characteristicUUID = characteristicUUID
//  }
}
