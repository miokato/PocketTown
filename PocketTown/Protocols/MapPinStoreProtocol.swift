//
//  MapPinStoreProtocol.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/27.
//

import SwiftUI
import SwiftData
import Observation
import CoreLocation

@MainActor
protocol MapPinStoreProtocol {
    var publicMapPins: [MapPin] { get set }
    
    func fetchPublicPins(around: CLLocation)
    func addPin(_ pin: MapPin, withContext context: ModelContext, isPublic: Bool)
    func removePin(_ pin: MapPin, withContext context: ModelContext)
    func togglePublic(pin: MapPin, makePublic: Bool) async
}

@MainActor @Observable
final class MapPinStoreMock: MapPinStoreProtocol {
    var publicMapPins: [MapPin] = []
    
    func fetchPublicPins(around: CLLocation) {}
    func addPin(_ pin: MapPin, withContext context: ModelContext, isPublic: Bool) {}
    func removePin(_ pin: MapPin, withContext context: ModelContext) {}
    func togglePublic(pin: MapPin, makePublic: Bool) async {}
}

@MainActor
struct MapPinStoreKey: @preconcurrency EnvironmentKey {
    static let defaultValue: any MapPinStoreProtocol = MapPinStoreMock()
}

extension EnvironmentValues {
    var mapPinStore: any MapPinStoreProtocol {
        get { self[MapPinStoreKey.self] }
        set { self[MapPinStoreKey.self] = newValue }
    }
}
