//
//  MapPinStore.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import Foundation
import SwiftUI
import SwiftData
import CloudKit

@Observable @MainActor
final class MapPinStore {
    
    // MARK: - Public Methods
    func addPin(_ pin: MapPin, withContext context: ModelContext) {
        Task {
            context.insert(pin)
            try? context.save()
        }
    }
    
    func removePin(_ pin: MapPin, withContext context: ModelContext) {
        context.delete(pin)
    }
    
    func togglePublic(pin: MapPin, makePublic: Bool) async {
        do {
            if makePublic {
                let id = try await CloudPublicService().publish(pin)
                pin.publicRecordName = id.recordName
            } else if let name = pin.publicRecordName {
                let id = CKRecord.ID(recordName: name)
                try await CloudPublicService().unpublish(recordID: id)
                pin.publicRecordName = nil
            }
        } catch {
            assertionFailure("Failed to toggle public status of a pin.")
            log("\(error)", with: .error)
        }
    }
}
