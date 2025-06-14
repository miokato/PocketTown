//
//  LocationError.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/14.
//

import CoreLocation

// MARK: - LocationError
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置情報の使用が許可されていません"
        case .locationUnavailable:
            return "現在位置を取得できません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}
