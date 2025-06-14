//
//  MainView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct MainView: View {
    @State private var locationStore = LocationStore()
    @State private var weatherStore: WeatherStore
    
    init() {
        let locationStore = LocationStore()
        self._locationStore = State(initialValue: locationStore)
        self._weatherStore = State(initialValue: WeatherStore(locationStore: locationStore))
    }
    
    var body: some View {
        HomeView()
            .environment(locationStore)
            .environment(weatherStore)
    }
}

#Preview {
    MainView()
}
