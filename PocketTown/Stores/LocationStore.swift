import CoreLocation
import SwiftUI

@Observable @MainActor
final class LocationStore {
    private let locationService = LocationService()
    private var locationTask: Task<Void, Never>?
    private var authorizationTask: Task<Void, Never>?
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: LocationError?
    
    // MARK: - Initialization
    init() {
        startMonitoringAuthorization()
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        Task {
            await locationService.requestLocationPermission()
        }
    }
    
    func startLocationUpdates() {
        Task {
            await locationService.startLocationUpdates()
        }
    }
    
    func stopLocationUpdates() {
        Task {
            await locationService.stopLocationUpdates()
        }
    }
    
    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                for await location in locationService.locationUpdates() {
                    continuation.yield(location)
                }
                
                continuation.finish()
            }
        }
    }
    
    // MARK: - Private Methods
    private func startMonitoringAuthorization() {
        authorizationTask?.cancel()
        authorizationTask = Task { [weak self] in
            guard let self else { return }
            
            for await status in locationService.authorizationUpdates() {
                await MainActor.run {
                    self.authorizationStatus = status
                    self.updateLocationError(for: status)
                }
            }
        }
        
        locationTask?.cancel()
        locationTask = Task { [weak self] in
            guard let self else { return }
            
            for await location in locationService.locationUpdates() {
                await MainActor.run {
                    self.currentLocation = location
                    self.locationError = nil
                }
            }
        }
    }
    
    private func updateLocationError(for status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
        case .denied, .restricted:
            locationError = LocationError.permissionDenied
        case .notDetermined:
            locationError = nil
        @unknown default:
            break
        }
    }
    
    deinit {
        Task { [weak self] in
            guard let self = self else { return }
            await locationTask?.cancel()
            await authorizationTask?.cancel()
        }
    }
}

