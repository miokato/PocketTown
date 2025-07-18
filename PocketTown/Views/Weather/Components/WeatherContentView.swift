//
//  WeatherContentView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

struct WeatherContentView: View {
    
    let weather: Weather
    
    // MARK: - Temperature Formatter
    private var temperatureFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                VStack(spacing: 8) {
                    // 天気アイコン
                    Image(systemName: weather.symbolName)
                        .font(.largeTitle)
                        .foregroundStyle(.tint)
                        .symbolRenderingMode(.multicolor)
                    // 天気の説明
                    Text(weather.description)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // 現在の気温
                    Text(temperatureFormatter.string(from: weather.temperature))
                        .font(.title2)
                        .foregroundColor(.textPrimary)
                    
                    // 最高/最低気温
                    HStack(spacing: 4) {
                        Label(temperatureFormatter.string(from: weather.temperatureMax), systemImage: "arrow.up")
                            .font(.caption2)
                            .foregroundColor(.red)
                        Label(temperatureFormatter.string(from: weather.temperatureMin), systemImage: "arrow.down")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    // 湿度
                    Label("\(Int(weather.humidity * 100))%", systemImage: "humidity")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    
                }
            }
            AppleWeatherBadge()
        }
    }
}

#Preview {
    WeatherContentView(weather: Weather.sample)
}
