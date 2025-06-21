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
    private let cloudPublicService = CloudPublicService()
    
    // MARK: - Public Methods
    func addPin(_ pin: MapPin, withContext context: ModelContext, isPublic: Bool) {
        Task {
            context.insert(pin)
            if isPublic {
                let id = try await cloudPublicService.publish(pin)
                pin.publicRecordName = id.recordName
            }
            try? context.save()
        }
    }
    
    func removePin(_ pin: MapPin, withContext context: ModelContext) {
        removePublicPinIfNeeded(for: pin)
        context.delete(pin)
    }
    
    /// PublicRecordNameが登録されているときはiCloudのpublicDBに入っているピンのデータを削除する
    private func removePublicPinIfNeeded(for pin: MapPin) {
        if let name = pin.publicRecordName {
            let id = CKRecord.ID(recordName: name)
            removePublicPin(id: id)
            pin.publicRecordName = nil
        }
    }
    
    private func removePublicPin(id: CKRecord.ID) {
        Task {
            try await cloudPublicService.unpublish(recordID: id)
        }
    }
    
    func togglePublic(pin: MapPin, makePublic: Bool) async {
        do {
            if makePublic {
                let id = try await cloudPublicService.publish(pin)
                pin.publicRecordName = id.recordName
            } else if let name = pin.publicRecordName {
                let id = CKRecord.ID(recordName: name)
                try await cloudPublicService.unpublish(recordID: id)
                pin.publicRecordName = nil
            }
        } catch {
            assertionFailure("Failed to toggle public status of a pin.")
            log("\(error)", with: .error)
        }
    }
}
