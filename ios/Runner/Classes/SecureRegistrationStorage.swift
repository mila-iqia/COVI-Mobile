//
//  SecureRegistrationStorage.swift
//  Sonar
//
//  Created by NHSX on 3/24/20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Security

struct PartialRegistration: Codable, Equatable {
    let id: UUID
    let secretKey: Data

    init(id: UUID, secretKey: Data) {
        self.id = id
        self.secretKey = secretKey
    }
}

class SecureRegistrationStorage {

    enum Error: Swift.Error {
        case invalidSecretKey
        case keychain(OSStatus)
    }

    func get() -> PartialRegistration? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secService,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess: break
        case errSecItemNotFound: return nil
        default:
            NSLog("error: Could not read registraton data from keychain due to unhandled status from SecItemCopy: \(status)")
            return nil
        }

        guard let item = result as? [String : Any],
            let data = item[kSecValueData as String] as? Data,
            let idString = item[kSecAttrAccount as String] as? String,
            let id = UUID(uuidString: idString) else {
                NSLog("error: No registration data in keychain")
                return nil
        }

        return PartialRegistration(id: id, secretKey: data)
    }

    func set(registration: PartialRegistration) throws {
        try clear()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secService,
            kSecAttrAccount as String: registration.id.uuidString,
            kSecValueData as String: registration.secretKey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess || status == errSecDuplicateItem else {
            NSLog("error: Failed to add registration to keychain: \(status)")
            throw Error.keychain(status)
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secService,
        ]
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            NSLog("error: Failed to add clear registration from keychain : \(status)")
            throw Error.keychain(status)
        }
    }

}

fileprivate let secService = "registration"
