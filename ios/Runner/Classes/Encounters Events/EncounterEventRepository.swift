//
//  EncounterEventRepository.swift
//  Sonar
//
//  Created by NHSX on 31.03.20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

protocol EncounterEventRepositoryDelegate {
  
  func repository(_ repository: EncounterEventRepository, didRecord broadcastPayload: IncomingBroadcastPayload, for peripheral: BTLEPeripheral)
  
  func repository(_ repository: EncounterEventRepository, didRecordRSSI RSSI: Int, for peripheral: BTLEPeripheral)
  
}

protocol EncounterEventRepository: BTLEListenerDelegate {
  var encounterEvents: [EncounterEvent] { get }
  var delegate: EncounterEventRepositoryDelegate? { get set }
  func reset()
  func remove(through date: Date)
  func removeExpiredEncounterEvents(ttl: Double)
}

protocol EncounterEventPersister {
  var items: [UUID: EncounterEvent] { get }
  func update(item: EncounterEvent, key: UUID)
  func replaceAll(with: [UUID: EncounterEvent])
  func reset()
}

extension PlistPersister: EncounterEventPersister where K == UUID, V == EncounterEvent {
}

@objc class PersistingEncounterEventRepository: NSObject, EncounterEventRepository {
  
  public var encounterEvents: [EncounterEvent] {
    return Array(persister.items.values)
  }
  
  public var delegate: EncounterEventRepositoryDelegate?
  
  private var persister: EncounterEventPersister
  
  internal init(persister: EncounterEventPersister) {
    self.persister = persister
  }
  
  func reset() {
    persister.reset()
  }
  
  func remove(through date: Date) {
    // I doubt this is atomic, but the window should be extraordinarily small
    // so I'm not too worried about dropping encounter events here.
    let newItems = persister.items.filter { _, encounterEvent in encounterEvent.timestamp > date }
    persister.replaceAll(with: newItems)
  }
  
  func removeExpiredEncounterEvents(ttl: Double) {
    let expiryDate = Date(timeIntervalSinceNow: -ttl)
    remove(through: expiryDate)
  }
  
  func btleListener(_ listener: BTLEListener, didFind broadcastPayload: IncomingBroadcastPayload, for peripheral: BTLEPeripheral) {
    var event = persister.items[peripheral.identifier] ?? EncounterEvent()
    event.broadcastPayload = broadcastPayload
    persister.update(item: event, key: peripheral.identifier)
    delegate?.repository(self, didRecord: broadcastPayload, for: peripheral)
  }
  
  func btleListener(_ listener: BTLEListener, didReadTxPower txPower: Int, for peripheral: BTLEPeripheral) {
    var encounterEvent = persister.items[peripheral.identifier] ?? EncounterEvent()
    encounterEvent.txPower = Int8(txPower)
    persister.update(item: encounterEvent, key: peripheral.identifier)
  }
  
  func btleListener(_ listener: BTLEListener, didReadRSSI RSSI: Int, for peripheral: BTLEPeripheral) {
    var event = persister.items[peripheral.identifier] ?? EncounterEvent()
    event.recordRSSI(Int8(RSSI))
    persister.update(item: event, key: peripheral.identifier)
    delegate?.repository(self, didRecordRSSI: RSSI, for: peripheral)
  }
  
}

private let logger = Logger(label: "EncounterEvents")
