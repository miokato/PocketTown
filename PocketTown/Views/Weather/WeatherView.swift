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
    
    // MARK: - Body
    var body: some View {
        VStack {
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
        .frame(minHeight: 80)
        .padding()
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private func weatherContent(_ weather: Weather) -> some View {
        WeatherDateTimeView(weather: weather)
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
