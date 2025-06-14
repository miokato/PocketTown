//
//  MainView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct MainView: View {
    @State private var locationStore: LocationStore = .init()
    @State private var weatherStore: WeatherStore = .init()
    
    var body: some View {
        HomeView()
            .environment(locationStore)
            .environment(weatherStore)
    }
}

#Preview {
    MainView()
}
