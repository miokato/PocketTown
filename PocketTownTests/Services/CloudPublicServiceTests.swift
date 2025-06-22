//
//  CloudPublicServiceTests.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/22.
//

import Testing
import Foundation
import CloudKit
import CoreLocation
@testable import PocketTown

@Suite("CloudPublicService Tests with Mock")
struct CloudPublicServiceTests {
    
    // MARK: - Helper Methods
    
    @MainActor
    private func createMockService() -> (TestableCloudPublicService, MockCloudKitService) {
        let mockService = MockCloudKitService()
        let service = TestableCloudPublicService(mockService: mockService)
        return (service, mockService)
    }
    
    // MARK: - Test fetchMapPins
    
    @Test("fetchMapPins returns array of MapPins")
    @MainActor
    func testFetchMapPinsReturnsArray() async throws {
        // Given
        let (service, mockService) = createMockService()
        
        // When
        let pins = try await service.fetchMapPins()
        
        // Then
        #expect(pins.count == 3) // Mock has 3 pins
        #expect(mockService.fetchCallCount == 1)
        #expect(pins.allSatisfy { $0.isPublic })
        
        print("Successfully fetched \(pins.count) mock pins")
    }
    
    @Test("fetchMapPins handles empty results")
    @MainActor
    func testFetchMapPinsEmptyResult() async throws {
        // Given
        let (service, mockService) = createMockService()
        mockService.mockPins = [] // No pins
        
        // When
        let pins = try await service.fetchMapPins()
        
        // Then
        #expect(pins.isEmpty)
        #expect(mockService.fetchCallCount == 1)
        
        print("Successfully handled empty result")
    }
    
    @Test("fetchMapPins handles pagination correctly")
    @MainActor
    func testFetchMapPinsPagination() async throws {
        // Given
        let (service, mockService) = createMockService()
        
        // Create many pins to test pagination
        var manyPins: [MapPin] = []
        for i in 0..<75 { // More than one page (50 per page)
            let pin = MapPin(
                title: "Pin \(i)",
                note: "Note \(i)",
                latitude: 35.6812 + Double(i) * 0.001,
                longitude: 139.7671 + Double(i) * 0.001,
                isPublic: true
            )
            manyPins.append(pin)
        }
        mockService.mockPins = manyPins
        
        // When
        let pins = try await service.fetchMapPins()
        
        // Then
        #expect(pins.count == 75)
        
        // Check for duplicate IDs (pagination bug would cause duplicates)
        let uniqueIds = Set(pins.map { $0.id })
        #expect(uniqueIds.count == pins.count, "No duplicate pins should be fetched")
        
        print("Pagination test passed with \(pins.count) pins")
    }
    
    @Test("fetchMapPins correctly parses MapPin properties")
    @MainActor
    func testFetchMapPinsParsing() async throws {
        // Given
        let (service, _) = createMockService()
        
        // When
        let pins = try await service.fetchMapPins()
        
        // Then
        let firstPin = pins.first!
        #expect(firstPin.title == "カフェ青山")
        #expect(firstPin.note == "静かで落ち着いた雰囲気")
        #expect(firstPin.latitude == 35.6812)
        #expect(firstPin.longitude == 139.7671)
        #expect(firstPin.isPublic == true)
        
        print("Property parsing test passed")
    }
    
    @Test("fetchMapPins handles network error")
    @MainActor
    func testFetchMapPinsNetworkError() async throws {
        // Given
        let (service, mockService) = createMockService()
        mockService.shouldThrowError = true
        
        // When & Then
        do {
            _ = try await service.fetchMapPins()
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is CKError)
            print("Network error handled correctly")
        }
    }
    
    // MARK: - Test publish
    
    @Test("publish creates new public record for pin")
    @MainActor
    func testPublishNewPin() async throws {
        // Given
        let (service, mockService) = createMockService()
        let testPin = MapPin(
            title: "Test Pin",
            note: "Test note for unit testing",
            latitude: 35.6812,
            longitude: 139.7671,
            isPublic: true
        )
        
        // When
        let recordID = try await service.publish(testPin)
        
        // Then
        #expect(!recordID.recordName.isEmpty)
        #expect(mockService.publishCallCount == 1)
        
        print("Publish new pin test passed")
    }
    
    @Test("publish returns existing record ID for pin with publicRecordName")
    @MainActor
    func testPublishExistingPin() async throws {
        // Given
        let (service, mockService) = createMockService()
        let existingRecordName = "test-record-123"
        let testPin = MapPin(
            title: "Test Pin",
            note: "Test note",
            latitude: 35.6812,
            longitude: 139.7671,
            isPublic: true
        )
        testPin.publicRecordName = existingRecordName
        
        // When
        let recordID = try await service.publish(testPin)
        
        // Then
        #expect(recordID.recordName == existingRecordName)
        #expect(mockService.publishCallCount == 0) // Should not call save
        
        print("Publish existing pin test passed")
    }
    
    @Test("publish handles network error")
    @MainActor
    func testPublishNetworkError() async throws {
        // Given
        let (service, mockService) = createMockService()
        mockService.shouldThrowError = true
        let testPin = MapPin(
            title: "Test Pin",
            note: "Test note",
            latitude: 35.6812,
            longitude: 139.7671,
            isPublic: true
        )
        
        // When & Then
        do {
            _ = try await service.publish(testPin)
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is CKError)
            print("Publish network error handled correctly")
        }
    }
    
    // MARK: - Test unpublish
    
    @Test("unpublish removes public record")
    @MainActor
    func testUnpublish() async throws {
        // Given
        let (service, mockService) = createMockService()
        let recordID = CKRecord.ID(recordName: "test-record-to-delete")
        
        // When
        try await service.unpublish(recordID: recordID)
        
        // Then
        #expect(mockService.unpublishCallCount == 1)
        
        print("Unpublish test passed")
    }
    
    @Test("unpublish handles network error")
    @MainActor
    func testUnpublishNetworkError() async throws {
        // Given
        let (service, mockService) = createMockService()
        mockService.shouldThrowError = true
        let recordID = CKRecord.ID(recordName: "test-record")
        
        // When & Then
        do {
            try await service.unpublish(recordID: recordID)
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error is CKError)
            print("Unpublish network error handled correctly")
        }
    }
}

// MARK: - Integration Test with Mock

@Suite("CloudPublicService Integration Tests with Mock")
struct CloudPublicServiceIntegrationTests {
    
    @Test("Full lifecycle: create, fetch, and delete public pin")
    @MainActor
    func testFullPinLifecycle() async throws {
        // Given
        let mockService = MockCloudKitService()
        let service = TestableCloudPublicService(mockService: mockService)
        let testPin = MapPin(
            title: "Integration Test Pin",
            note: "Integration test note",
            latitude: 35.6812,
            longitude: 139.7671,
            isPublic: true
        )
        
        // When - Publish the pin
        let recordID = try await service.publish(testPin)
        #expect(mockService.publishCallCount == 1)
        
        // Then - Verify pins can be fetched
        let pins = try await service.fetchMapPins()
        #expect(pins.count == 3) // Original mock pins
        #expect(mockService.fetchCallCount == 1)
        
        // Cleanup - Delete the pin
        try await service.unpublish(recordID: recordID)
        #expect(mockService.unpublishCallCount == 1)
        
        print("Full lifecycle integration test passed")
    }
    
    @Test("Verify mock data consistency")
    @MainActor
    func testMockDataConsistency() async throws {
        // Given
        let mockService = MockCloudKitService()
        let service = TestableCloudPublicService(mockService: mockService)
        
        // When
        let pins = try await service.fetchMapPins()
        
        // Then
        #expect(pins.count == 3)
        
        let titles = pins.map { $0.title }
        #expect(titles.contains("カフェ青山"))
        #expect(titles.contains("公園前ベーカリー"))
        #expect(titles.contains("図書館"))
        
        print("Mock data consistency test passed")
    }
}
