import CoreLocation
import Foundation

actor LocationService: NSObject {
    private let locationManager: CLLocationManager
    private var locationContinuation: AsyncStream<CLLocation>.Continuation?
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        Task {
            await setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() async {
        await MainActor.run {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startLocationUpdates() async {
        await MainActor.run {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationUpdates() async {
        await MainActor.run {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationUpdates() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            self.locationContinuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.stopLocationUpdates()
                }
            }
        }
    }
    
    func authorizationUpdates() -> AsyncStream<CLAuthorizationStatus> {
        AsyncStream { continuation in
            self.authorizationContinuation = continuation
            Task { @MainActor in
                continuation.yield(locationManager.authorizationStatus)
            }
        }
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
