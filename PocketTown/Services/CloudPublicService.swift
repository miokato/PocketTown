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

    func fetchMapPins() async throws -> [MapPin] {
        let query = try await createPublicPinsQuery()
        return try await fetchAllRecords(using: query)
    }
    
    // MARK: - Private Methods
    
    /// 自分以外のユーザーが作成したパブリックピンを取得するクエリを作成
    private func createPublicPinsQuery() async throws -> CKQuery {
        // 自分が作成したピンを除外するため、userRecordIDを利用。
        // CloudKit Console側でも処理が必要
        // https://stackoverflow.com/questions/69610184/field-recordname-is-not-marked-queryable-cloudkit-dashboard
        let userRecordID = try await container.userRecordID()
        let myRef = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "creatorUserRecordID != %@", myRef)
        
        return CKQuery(
            recordType: "PublicPin",
            predicate: predicate
        )
    }
    
    /// 指定されたクエリを使用して、ページネーションですべてのレコードを取得
    private func fetchAllRecords(using query: CKQuery) async throws -> [MapPin] {
        var allPins: [MapPin] = []
        var cursor: CKQueryOperation.Cursor?
        
        repeat {
            let (records, nextCursor) = try await fetchRecordsPage(
                query: query,
                cursor: cursor
            )
            
            let pins = parseRecordsToMapPins(records)
            allPins.append(contentsOf: pins)
            
            cursor = nextCursor
        } while cursor != nil
        
        return allPins
    }
    
    /// 単一ページのレコードを取得
    private func fetchRecordsPage(
        query: CKQuery,
        cursor: CKQueryOperation.Cursor?
    ) async throws -> ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?) {
        
        if let cursor = cursor {
            // カーソルを使った継続クエリ
            return try await db.records(
                continuingMatchFrom: cursor,
                resultsLimit: 50
            )
        } else {
            // 初回クエリ
            return try await db.records(
                matching: query,
                resultsLimit: 50
            )
        }
    }
    
    /// CKRecordの配列をMapPinの配列に変換
    private func parseRecordsToMapPins(
        _ records: [(CKRecord.ID, Result<CKRecord, Error>)]
    ) -> [MapPin] {
        return records.compactMap { _, result in
            switch result {
            case .success(let record):
                return createMapPin(from: record)
            case .failure:
                return nil
            }
        }
    }
    
    /// CKRecordからMapPinを作成
    private func createMapPin(from record: CKRecord) -> MapPin {
        return MapPin(
            id: UUID(uuidString: record["id"] as? String ?? "") ?? UUID(),
            title: record["title"] as? String ?? "",
            note: record["note"] as? String ?? "",
            timestamp: record["timestamp"] as? Date ?? .distantPast,
            latitude: (record["location"] as? CLLocation)?.coordinate.latitude ?? 0,
            longitude: (record["location"] as? CLLocation)?.coordinate.longitude ?? 0,
            isPublic: true
        )
    }
}
