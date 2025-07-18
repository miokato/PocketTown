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
            Spacer()
            WeatherContentView(weather: weather)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    WeatherDateTimeView(weather: Weather.sample)
}
