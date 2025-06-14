import Foundation
import WeatherKit

struct Weather {
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
            return "晴れ"
        case .cloudy:
            return "曇り"
        case .rain:
            return "雨"
        case .snow:
            return "雪"
        case .sleet:
            return "みぞれ"
        case .hail:
            return "ひょう"
        case .thunderstorms:
            return "雷雨"
        case .tropicalStorm:
            return "熱帯低気圧"
        case .hurricane:
            return "ハリケーン"
        case .smoky:
            return "煙霧"
        case .haze:
            return "もや"
        case .windy:
            return "強風"
        case .frigid:
            return "極寒"
        case .hot:
            return "猛暑"
        case .flurries:
            return "にわか雪"
        case .partlyCloudy:
            return "晴れ時々曇り"
        case .mostlyClear:
            return "おおむね晴れ"
        case .mostlyCloudy:
            return "おおむね曇り"
        case .drizzle:
            return "霧雨"
        case .heavyRain:
            return "大雨"
        case .heavySnow:
            return "大雪"
        case .sunFlurries:
            return "晴れ時々雪"
        case .sunShowers:
            return "晴れ時々雨"
        case .isolatedThunderstorms:
            return "ところにより雷雨"
        case .scatteredThunderstorms:
            return "ところどころ雷雨"
        case .strongStorms:
            return "激しい嵐"
        case .blizzard:
            return "吹雪"
        case .blowingDust:
            return "砂塵"
        case .blowingSnow:
            return "地吹雪"
        case .freezingDrizzle:
            return "着氷性の霧雨"
        case .freezingRain:
            return "着氷性の雨"
        case .wintryMix:
            return "雨雪混じり"
        case .breezy:
            return "そよ風"
        case .foggy:
            return "霧"
        @unknown default:
            return "不明"
        }
    }
}
