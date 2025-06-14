import Foundation
import CoreLocation
import SwiftUI

@Observable
final class WeatherStore {
    // MARK: - Properties
    private let weatherService = WeatherService()
    
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
            return "ネットワークエラーが発生しました"
        case .locationUnavailable:
            return "位置情報を取得できません"
        case .serviceUnavailable:
            return "天気情報サービスが利用できません"
        }
    }
}
