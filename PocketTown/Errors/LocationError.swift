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
            return String(localized: "error.location.permission")
        case .locationUnavailable:
            return String(localized: "error.location.unavailable")
        case .networkError:
            return String(localized: "error.network")
        }
    }
}
