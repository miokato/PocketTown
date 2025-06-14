import CoreLocation
import SwiftUI

@Observable
final class LocationStore: NSObject {
    private let locationManager = CLLocationManager()
    private var locationContinuation: AsyncStream<CLLocation>.Continuation?
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: LocationError?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            self.locationContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                self?.stopLocationUpdates()
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationStore: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            startLocationUpdates()
        case .denied, .restricted:
            locationError = LocationError.permissionDenied
            stopLocationUpdates()
        case .notDetermined:
            locationError = nil
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationContinuation?.yield(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        locationError = error
    }
}

