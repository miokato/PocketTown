//
//  UserDefaultsStorage.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import Foundation

/// UserDefaultsを利用してローカルにデータを保存する
struct UserDefaultsStorage {
    static let shared = UserDefaultsStorage()
    
    func save<T: Encodable>(_ value: T, withKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
}
