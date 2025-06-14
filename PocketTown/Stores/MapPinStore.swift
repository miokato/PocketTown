//
//  MapPinStore.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import SwiftUI

@Observable
final class MapPinStore {
    // MARK: - Properties
    var pins: [MapPin] = []
    
    // MARK: - Public Methods
    func addPin(_ pin: MapPin) {
        pins.append(pin)
    }
    
    func removePin(id: UUID) {
        pins.removeAll { $0.id == id }
    }
    
    func getPin(by id: UUID) -> MapPin? {
        pins.first { $0.id == id }
    }
}