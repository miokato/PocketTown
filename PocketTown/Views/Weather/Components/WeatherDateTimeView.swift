//
//  WeatherDateTimeView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

public struct WeatherDateTimeView: View {
    let weather: Weather
    
    public var body: some View {
        HStack {
            DateTimeView()
            WeatherContentView(weather: weather)
        }
        .background(.thinMaterial)
    }
}

#Preview {
    WeatherDateTimeView(weather: Weather.sample)
}
