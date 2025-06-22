//
//  User.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/23.
//

import CoreLocation

struct UserLocation: Sendable, Codable {
    var latitude: Double
    var longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: - Computed Properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var userDefautlsKey: String {
        "UserLocation"
    }
}
