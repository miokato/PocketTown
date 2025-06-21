//
//  MapPin.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import CoreLocation
import SwiftData
import CloudKit

@Model
final class MapPin: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var note: String = ""
    var timestamp: Date = Date()
    var latitude: Double = 0
    var longitude: Double = 0
    var isPublic: Bool = false
    var publicRecordName: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String,
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double,
        isPublic: Bool
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.isPublic = isPublic
    }
    
    // MARK: - Computed Properties
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


extension MapPin {
    
    static func makeSample(_ coordinate: CLLocationCoordinate2D) -> MapPin {
        return MapPin(title: "", note: "", latitude: coordinate.latitude, longitude: coordinate.longitude, isPublic: false)
    }
    /// Privacy-friendly 10 m グリッドに丸める
    private var roundedCoord: CLLocation {
        func round10m(_ value: Double) -> Double {
            (value * 1e4).rounded() / 1e4
        }
        return CLLocation(latitude:  round10m(latitude),
                          longitude: round10m(longitude))
    }

    /// Public 用 CKRecord を生成
    func makePublicRecord() -> CKRecord {
        let record = CKRecord(recordType: "PublicPin")
        record["id"] = id.uuidString as CKRecordValue
        record["title"] = title as CKRecordValue
        record["note"] = note as CKRecordValue
        record["timestamp"] = timestamp as CKRecordValue
        record["isPublic"] = true as CKRecordValue
        record["location"] = roundedCoord
        return record
    }
}
