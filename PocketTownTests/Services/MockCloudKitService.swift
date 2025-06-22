//
//  MockCloudKitService.swift
//  PocketTownTests
//
//  Created by Claude on 2025/06/22.
//

import Foundation
import CloudKit
import CoreLocation
@testable import PocketTown

// MARK: - Mock Cursor

final class MockQueryCursor {
    let pageNumber: Int
    
    init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
}

// MARK: - Mock Data

final class MockCloudKitService {
    var mockPins: [MapPin] = []
    var shouldThrowError = false
    var publishCallCount = 0
    var unpublishCallCount = 0
    var fetchCallCount = 0
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Create mock pins
        mockPins = [
            MapPin(
                id: UUID(),
                title: "カフェ青山",
                note: "静かで落ち着いた雰囲気",
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                latitude: 35.6812,
                longitude: 139.7671,
                isPublic: true
            ),
            MapPin(
                id: UUID(),
                title: "公園前ベーカリー",
                note: "朝食におすすめ",
                timestamp: Date().addingTimeInterval(-172800), // 2 days ago
                latitude: 35.6825,
                longitude: 139.7685,
                isPublic: true
            ),
            MapPin(
                id: UUID(),
                title: "図書館",
                note: "勉強や読書に最適",
                timestamp: Date().addingTimeInterval(-259200), // 3 days ago
                latitude: 35.6798,
                longitude: 139.7658,
                isPublic: true
            )
        ]
    }
}

// MARK: - CloudKit Database Protocol

protocol CloudKitDatabaseProtocol {
    func records(matching query: CKQuery, resultsLimit: Int) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: MockQueryCursor?)
    func records(continuingMatchFrom cursor: MockQueryCursor, resultsLimit: Int) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: MockQueryCursor?)
    func save(_ record: CKRecord) async throws -> CKRecord
    func deleteRecord(withID recordID: CKRecord.ID) async throws
}

// MARK: - Mock CloudKit Database

final class MockCloudKitDatabase: CloudKitDatabaseProtocol {
    let mockService: MockCloudKitService
    private var savedRecords: [CKRecord.ID: CKRecord] = [:]
    private var allRecords: [(CKRecord.ID, Result<CKRecord, Error>)] = []
    private var hasGeneratedRecords = false
    
    init(mockService: MockCloudKitService) {
        self.mockService = mockService
    }
    
    func reset() {
        allRecords = []
        hasGeneratedRecords = false
        savedRecords = [:]
    }
    
    func records(matching query: CKQuery, resultsLimit: Int) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: MockQueryCursor?) {
        mockService.fetchCallCount += 1
        
        if mockService.shouldThrowError {
            throw CKError(.networkFailure)
        }
        
        // Generate records once per test
        if !hasGeneratedRecords {
            allRecords = mockService.mockPins.map { pin -> (CKRecord.ID, Result<CKRecord, Error>) in
                let record = CKRecord(recordType: "PublicPin")
                record["id"] = pin.id.uuidString
                record["title"] = pin.title
                record["note"] = pin.note
                record["timestamp"] = pin.timestamp
                record["location"] = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
                record["isPublic"] = true
                
                return (record.recordID, .success(record))
            }
            hasGeneratedRecords = true
        }
        
        // Return first page
        let pageSize = min(resultsLimit, allRecords.count)
        let pageRecords = Array(allRecords.prefix(pageSize))
        
        // Return cursor if there are more records than page size
        let hasMorePages = allRecords.count > pageSize
        let cursor = hasMorePages ? MockQueryCursor(pageNumber: 1) : nil
        
        return (pageRecords, cursor)
    }
    
    func records(continuingMatchFrom cursor: MockQueryCursor, resultsLimit: Int) async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: MockQueryCursor?) {
        mockService.fetchCallCount += 1
        
        if mockService.shouldThrowError {
            throw CKError(.networkFailure)
        }
        
        // Calculate pagination
        let pageSize = resultsLimit
        let startIndex = cursor.pageNumber * pageSize
        let endIndex = min(startIndex + pageSize, allRecords.count)
        
        // Return empty if no more records
        if startIndex >= allRecords.count {
            return ([], nil)
        }
        
        // Get records for this page
        let pageRecords = Array(allRecords[startIndex..<endIndex])
        
        // Return cursor if there are more pages
        let hasMorePages = endIndex < allRecords.count
        let nextCursor = hasMorePages ? MockQueryCursor(pageNumber: cursor.pageNumber + 1) : nil
        
        return (pageRecords, nextCursor)
    }
    
    func save(_ record: CKRecord) async throws -> CKRecord {
        mockService.publishCallCount += 1
        
        if mockService.shouldThrowError {
            throw CKError(.networkFailure)
        }
        
        savedRecords[record.recordID] = record
        return record
    }
    
    func deleteRecord(withID recordID: CKRecord.ID) async throws {
        mockService.unpublishCallCount += 1
        
        if mockService.shouldThrowError {
            throw CKError(.networkFailure)
        }
        
        savedRecords.removeValue(forKey: recordID)
    }
}

// MARK: - Mock CloudKit Container

final class MockCloudKitContainer {
    let mockService: MockCloudKitService
    let mockDatabase: MockCloudKitDatabase
    
    init(mockService: MockCloudKitService) {
        self.mockService = mockService
        self.mockDatabase = MockCloudKitDatabase(mockService: mockService)
    }
    
    func userRecordID() async throws -> CKRecord.ID {
        if mockService.shouldThrowError {
            throw CKError(.networkFailure)
        }
        return CKRecord.ID(recordName: "mock-user-id")
    }
}

// MARK: - Testable CloudPublicService

@MainActor
final class TestableCloudPublicService {
    private let mockContainer: MockCloudKitContainer
    private let mockDatabase: MockCloudKitDatabase
    
    init(mockService: MockCloudKitService) {
        self.mockContainer = MockCloudKitContainer(mockService: mockService)
        self.mockDatabase = mockContainer.mockDatabase
    }
    
    func fetchMapPins() async throws -> [MapPin] {
        // 自分が作成したピンを除外するため、userRecordIDを利用。
        let userRecordID = try await mockContainer.userRecordID()
        let myRef = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format:"creatorUserRecordID != %@", myRef)
        let query = CKQuery(
            recordType: "PublicPin",
            predicate: predicate
        )
        
        var all: [MapPin] = []
        var cursor: MockQueryCursor?
        var isFirstQuery = true
        
        repeat {
            let matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]
            let nextCursor: MockQueryCursor?
            
            if isFirstQuery {
                // 初回クエリ
                (matchResults, nextCursor) = try await mockDatabase.records(
                    matching: query,
                    resultsLimit: 50
                )
                isFirstQuery = false
            } else if let cursor = cursor {
                // カーソルを使った継続クエリ
                (matchResults, nextCursor) = try await mockDatabase.records(
                    continuingMatchFrom: cursor,
                    resultsLimit: 50
                )
            } else {
                break
            }
            
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
            let saved = try await mockDatabase.save(rec)
            return saved.recordID
        }
    }

    /// 公開 OFF
    func unpublish(recordID: CKRecord.ID) async throws {
        try await mockDatabase.deleteRecord(withID: recordID)
    }
}
