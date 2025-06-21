//
//  CloudPublicService.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/18.
//

import CloudKit

@MainActor
final class CloudPublicService {
    private let container = CKContainer(
        identifier: "iCloud.co.utomica.PocketTown"
    )
    private var db: CKDatabase {
        container.publicCloudDatabase
    }
    
    func fetchMapPins() async throws -> [MapPin] {
        // 自分が作成したピンを除外するため、userRecordIDを利用。
        // CloudKit Console側でも処理が必要
        // https://stackoverflow.com/questions/69610184/field-recordname-is-not-marked-queryable-cloudkit-dashboard
        let userRecordID = try await container.userRecordID()
        let myRef = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format:"creatorUserRecordID != %@", myRef)
        let query = CKQuery(
            recordType: "PublicPin",
            predicate: predicate
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
