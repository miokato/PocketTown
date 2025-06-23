@preconcurrency import CoreLocation
import Foundation

@MainActor
final class LocationService: NSObject {
    static let shared = LocationService()
    
    private let locationManager: CLLocationManager
    private var locationContinuation: AsyncStream<CLLocation>.Continuation?
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() async {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() async {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() async {
        locationManager.stopUpdatingLocation()
    }
    
    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            self.locationContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.stopLocationUpdates()
                }
            }
        }
    }
    
    func authorizationUpdates() -> AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            self.authorizationContinuation = continuation
            continuation.yield(locationManager.authorizationStatus)
        }
    }
    
    // MARK: - private methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            await authorizationContinuation?.yield(manager.authorizationStatus)
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                await startLocationUpdates()
            case .denied, .restricted, .notDetermined:
                await stopLocationUpdates()
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            await locationContinuation?.yield(location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await MainActor.run {
                log("Location error: \(error)", with: .error)
            }
        }
    }
}
