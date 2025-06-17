//
//  MapPin.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import CoreLocation
import SwiftData

@Model
final class MapPin: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var timestamp: Date = Date()
    var latitude: Double = 0
    var longitude: Double = 0
    
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
