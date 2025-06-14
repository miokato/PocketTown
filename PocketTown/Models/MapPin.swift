//
//  MapPin.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import CoreLocation

struct MapPin: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    
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
