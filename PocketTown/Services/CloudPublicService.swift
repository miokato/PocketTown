//
//  CloudPublicService.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/18.
//

import CloudKit

@MainActor
final class CloudPublicService {
    private let db = CKContainer(
        identifier: "iCloud.co.utomica.PocketTown"
    ).publicCloudDatabase
    
    func fetchMapPins() async throws -> [MapPin] {
        let query = CKQuery(
            recordType: "PublicPin",
            predicate: NSPredicate(value: true)
        )
        
        var all: [MapPin] = []
        var cursor: CKQueryOperation.Cursor?
        
        repeat {
            let (matchResults, nextCursor) = try await db.records(
                matching: query,
                resultsLimit: 50
//                cursor: cursor
            )
            
            for (_, result) in matchResults {
                if case .success(let record) = result {
                    all.append(MapPin(
                        id: UUID(uuidString: record["id"] as? String ?? "") ?? UUID(),
                        title: record["title"] as? String ?? "",
                        note:  record["note"]  as? String ?? "",
                        timestamp: record["timestamp"] as? Date ?? .distantPast,
                        latitude:  (record["location"]  as? CLLocation)?.coordinate.latitude ?? 0,
                        longitude:  (record["location"]  as? CLLocation)?.coordinate.longitude ?? 0,
                        isPublic: true
                    ))
                }
            }
            cursor = nextCursor
        } while cursor != nil
        
        return all
    }

    /// 公開 ON
    func publish(_ pin: MapPin) async throws -> CKRecord.ID {
        if let publicRecordName = pin.publicRecordName {
            let id = CKRecord.ID(recordName: publicRecordName)
            return id
        } else {
            let rec = pin.makePublicRecord()
            let saved = try await db.save(rec)
            return saved.recordID
        }
    }

    /// 公開 OFF
    func unpublish(recordID: CKRecord.ID) async throws {
        try await db.deleteRecord(withID: recordID)
    }
}
