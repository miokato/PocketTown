//
//  MapPinStore.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class MapPinStore {
    
    // MARK: - Public Methods
    func addPin(_ pin: MapPin, withContext context: ModelContext) {
        context.insert(pin)
    }
    
    func removePin(_ pin: MapPin, withContext context: ModelContext) {
        context.delete(pin)
    }
}
