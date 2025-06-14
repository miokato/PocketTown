import Foundation
import CoreLocation
import SwiftUI

@Observable
final class WeatherStore {
    // MARK: - Properties
    private let weatherService = WeatherService()
    private let locationStore: LocationStore
    private var updateTask: Task<Void, Never>?
    
    var weather: Weather?
    var isLoading = false
    var error: Error?
    
    // MARK: - Initialization
    init(locationStore: LocationStore) {
        self.locationStore = locationStore
    }
    
    // MARK: - Public Methods
    func startObservingLocation() {
        updateTask?.cancel()
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            
            for await location in self.locationStore.locationUpdates() {
                await self.updateWeather(for: location)
            }
        }
    }
    
    func stopObservingLocation() {
        updateTask?.cancel()
        updateTask = nil
    }
    
    func refreshWeather() async {
        guard let location = locationStore.currentLocation else { return }
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