import CoreLocation
import SwiftUI

@Observable @MainActor
final class LocationStore {
    private let locationService = LocationService()
    private var locationTask: Task<Void, Never>?
    private var authorizationTask: Task<Void, Never>?
    
    var currentLocation: CLLocation?
    var selectedLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: LocationError?
    
    var savedUserLocation: CLLocation? {
        guard let userLocation = UserDefaultsStorage.shared.load(UserLocation.self, forKey: UserLocation.userDefautlsKey) else {
            return nil
        }
        return CLLocation(latitude: userLocation.latitude,
                          longitude: userLocation.longitude)
    }
    
    // MARK: - Initialization
    init() {
        startMonitoring()
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
    
    /// ユーザーの現在位置を保存
    func saveUserLocation(_ location: CLLocation) throws {
        let userLocation = UserLocation(latitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude)
        try UserDefaultsStorage.shared.save(userLocation, withKey: UserLocation.userDefautlsKey)
    }
    
    /// 現在位置でユーザーのホーム位置を更新
    func updateUserLocation() {
        guard let currentLocation = currentLocation else { return }
        do {
            try saveUserLocation(currentLocation)
        } catch {
            log("\(error)", with: .error)
        }
    }

    // MARK: - Private Methods
    
    /// まだユーザー位置を保存してなければ保存
    private func saveUserLocationIfNeeded(_ location: CLLocation) {
        guard UserDefaultsStorage.shared.load(UserLocation.self, forKey: UserLocation.userDefautlsKey) == nil else {
            return
        }
        do {
            try saveUserLocation(location)
        } catch {
            log("\(error)", with: .error)
        }
    }
    
    private func startMonitoring() {
        startMonitoringAuthorization()
        startMonitoringLocation()
    }
    
    private func startMonitoringLocation() {
        locationTask?.cancel()
        locationTask = Task { [weak self] in
            guard let self else { return }
            
            for await location in locationService.locationUpdates() {
                await MainActor.run {
                    self.currentLocation = location
                    self.locationError = nil
                    saveUserLocationIfNeeded(location)
                }
            }
        }
    }
    
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

