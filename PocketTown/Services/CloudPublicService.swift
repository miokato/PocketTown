//
//  CloudPublicService.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/18.
//

import CloudKit

actor CloudPublicService {
    private let db = CKContainer(identifier: "iCloud.co.utomica.PocketTown")
                  .publicCloudDatabase

    /// 公開 ON
    func publish(_ pin: MapPin) async throws -> CKRecord.ID {
        let rec = pin.makePublicRecord()
        let saved = try await db.save(rec)
        return saved.recordID
    }

    /// 公開 OFF
    func unpublish(recordID: CKRecord.ID) async throws {
        try await db.deleteRecord(withID: recordID)
    }
}
