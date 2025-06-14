import Foundation
@preconcurrency import WeatherKit

struct Weather: Sendable, Codable {
    let condition: WeatherCondition
    let temperature: Measurement<UnitTemperature>
    let temperatureMax: Measurement<UnitTemperature>
    let temperatureMin: Measurement<UnitTemperature>
    let humidity: Double
    let symbolName: String
    let description: String
    
    init(from current: CurrentWeather, dailyForecast: DayWeather? = nil) {
        self.condition = current.condition
        self.temperature = current.temperature
        self.humidity = current.humidity
        self.symbolName = current.symbolName
        self.description = current.condition.description
        
        if let daily = dailyForecast {
            self.temperatureMax = daily.highTemperature
            self.temperatureMin = daily.lowTemperature
        } else {
            self.temperatureMax = current.temperature
            self.temperatureMin = current.temperature
        }
    }
}

extension WeatherCondition {
    var description: String {
        switch self {
        case .clear:
            return String(localized: "weather.condition.clear")
        case .cloudy:
            return String(localized: "weather.condition.cloudy")
        case .rain:
            return String(localized: "weather.condition.rain")
        case .snow:
            return String(localized: "weather.condition.snow")
        case .sleet:
            return String(localized: "weather.condition.sleet")
        case .hail:
            return String(localized: "weather.condition.hail")
        case .thunderstorms:
            return String(localized: "weather.condition.thunderstorm")
        case .tropicalStorm:
            return String(localized: "weather.condition.tropicalStorm")
        case .hurricane:
            return String(localized: "weather.condition.hurricane")
        case .smoky:
            return String(localized: "weather.condition.smoky")
        case .haze:
            return String(localized: "weather.condition.haze")
        case .windy:
            return String(localized: "weather.condition.windy")
        case .frigid:
            return String(localized: "weather.condition.frigid")
        case .hot:
            return String(localized: "weather.condition.hot")
        case .flurries:
            return String(localized: "weather.condition.flurries")
        case .partlyCloudy:
            return String(localized: "weather.condition.partlyCloudy")
        case .mostlyClear:
            return String(localized: "weather.condition.mostlyClear")
        case .mostlyCloudy:
            return String(localized: "weather.condition.mostlyCloudy")
        case .drizzle:
            return String(localized: "weather.condition.drizzle")
        case .heavyRain:
            return String(localized: "weather.condition.heavyRain")
        case .heavySnow:
            return String(localized: "weather.condition.heavySnow")
        case .sunFlurries:
            return String(localized: "weather.condition.sunFlurries")
        case .sunShowers:
            return String(localized: "weather.condition.sunShowers")
        case .isolatedThunderstorms:
            return String(localized: "weather.condition.isolatedThunderstorms")
        case .scatteredThunderstorms:
            return String(localized: "weather.condition.scatteredThunderstorms")
        case .strongStorms:
            return String(localized: "weather.condition.strongStorms")
        case .blizzard:
            return String(localized: "weather.condition.blizzard")
        case .blowingDust:
            return String(localized: "weather.condition.dust")
        case .blowingSnow:
            return String(localized: "weather.condition.blowingSnow")
        case .freezingDrizzle:
            return String(localized: "weather.condition.freezingDrizzle")
        case .freezingRain:
            return String(localized: "weather.condition.freezingRain")
        case .wintryMix:
            return String(localized: "weather.condition.wintryMix")
        case .breezy:
            return String(localized: "weather.condition.breezy")
        case .foggy:
            return String(localized: "weather.condition.foggy")
        @unknown default:
            return String(localized: "weather.condition.unknown")
        }
    }
}
