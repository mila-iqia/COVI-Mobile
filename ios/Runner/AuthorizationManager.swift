//
//  AuthorizationManager.swift
//  Sonar
//
//  Created by NHSX on 3/31/20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import CoreBluetooth
import Foundation

class AuthorizationManager: AuthorizationManaging {
    
    // WARNING: Don't call this except in situations where it's certain that the nursery will
    // have been started already (or at least, very soon). If the nursery is not started, the
    // completion handler will never be called.
    func waitForDeterminedBluetoothAuthorizationStatus(
        completion: @escaping (BluetoothAuthorizationStatus) -> Void
    ) {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if #available(iOS 13.1, *) {
                switch CBManager.authorization {
                case .notDetermined:
                    return
                    
                case .allowedAlways:
                    completion(.allowed)
                    timer.invalidate()
                    
                default:
                    completion(.denied)
                    timer.invalidate()
                }
            } else {
                switch CBPeripheralManager.authorizationStatus() {
                    
                case .notDetermined:
                    return
                    
                case .authorized:
                    completion(.allowed)
                    timer.invalidate()
                    
                default:
                    completion(.denied)
                    timer.invalidate()
                }
            }
        }
    }
    
    var bluetooth: BluetoothAuthorizationStatus {
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .denied
            case .denied:
                return .denied
            case .allowedAlways:
                return .allowed
            @unknown default:
                fatalError()
            }
        } else {
            switch CBPeripheralManager.authorizationStatus() {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .denied
            case .denied:
                return .denied
            case .authorized:
                return .allowed
            @unknown default:
                fatalError()
            }
        }
    }
}
