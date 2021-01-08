//
//  BroadcastPayload.swift
//  SonarTests
//
//  Created by NHSX on 30.04.20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import CommonCrypto
import Logging

struct BroadcastPayload {
  func data() -> Data {
    var payload = Data()
    
    payload.append(Data(Ble.shared.DH_Key))
    
    return payload
  }
}

struct IncomingBroadcastPayload: Equatable, Codable {
  let dh_key : Data
  
  init(data: Data) {
    self.dh_key = data;
    
    //  add to encounters array
  }
}

fileprivate let logger = Logger(label: "BTLE")
