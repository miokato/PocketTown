import Foundation
import CoreLocation
import SwiftUI

@Observable @MainActor
final class WeatherStore {
    // MARK: - Properties
    private let weatherService = WeatherService.shared
    
    var weather: Weather?
    var isLoading = false
    var error: Error?
    
    // MARK: - Public Methods
    func refreshWeather(by location: CLLocation?) async {
        guard let location = location else { return }
        await updateWeather(for: location)
    }
    
    // MARK: - Private Methods
    @MainActor
    private func updateWeather(for location: CLLocation) async {
        isLoading = true
        error = nil
        
        do {
            let weatherData = try await weatherService.fetchWeather(for: location)
            self.weather = weatherData
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - WeatherError
enum WeatherError: LocalizedError {
    case networkError
    case locationUnavailable
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return String(localized: "error.network")
        case .locationUnavailable:
            return String(localized: "error.location.unavailable")
        case .serviceUnavailable:
            return String(localized: "error.weather.unavailable")
        }
    }
}
