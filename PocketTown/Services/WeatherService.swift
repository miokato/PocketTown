import Foundation
@preconcurrency import WeatherKit
import CoreLocation

actor WeatherService {
    static let shared = WeatherService()
    
    private let weatherService = WeatherKit.WeatherService()
    
    func fetchWeather(for location: CLLocation) async throws -> Weather {
        let weather = try await weatherService.weather(for: location)
        
        let dailyForecast = weather.dailyForecast.forecast.first
        
        return Weather(
            from: weather.currentWeather,
            dailyForecast: dailyForecast
        )
    }
}
