//
//  MapPin.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import CoreLocation

struct MapPin: Identifiable, Codable, Sendable {
    var id: UUID
    var title: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: - Computed Properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
