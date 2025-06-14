//
//  WeatherView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct WeatherView: View {
    // MARK: - Properties
    @Environment(WeatherStore.self) private var weatherStore
    @Environment(LocationStore.self) private var locationStore
    
    // MARK: - Temperature Formatter
    private var temperatureFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .short
        return formatter
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if weatherStore.isLoading {
                loadingView
            } else if let weather = weatherStore.weather {
                weatherContent(weather)
            } else if weatherStore.error != nil {
                errorView
            } else {
                emptyView
            }
        }
        .padding()
        .background(.regularMaterial)
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private func weatherContent(_ weather: Weather) -> some View {
        HStack(spacing: 20) {
            // 天気アイコン
            Image(systemName: weather.symbolName)
                .font(.system(size: 50))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.multicolor)
            
            VStack(alignment: .leading, spacing: 8) {
                // 天気の説明
                Text(weather.description)
                    .font(.headline)
                
                // 現在の気温
                HStack(spacing: 12) {
                    Text(temperatureFormatter.string(from: weather.temperature))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // 最高/最低気温
                    HStack(spacing: 4) {
                        Label(temperatureFormatter.string(from: weather.temperatureMax), systemImage: "arrow.up")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Label(temperatureFormatter.string(from: weather.temperatureMin), systemImage: "arrow.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // 湿度
                Label("\(Int(weather.humidity * 100))%", systemImage: "humidity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text(String(localized: "weather.loading.message"))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var errorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            
            Text(String(localized: "weather.error.unavailable"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(String(localized: "weather.button.retry")) {
                Task {
                    await weatherStore.refreshWeather(by: locationStore.currentLocation)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var emptyView: some View {
        HStack {
            Image(systemName: "cloud")
                .font(.title)
                .foregroundColor(.secondary)
            Text(String(localized: "weather.loading.message"))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeatherView()
        .environment(WeatherStore())
        .environment(LocationStore())
}
