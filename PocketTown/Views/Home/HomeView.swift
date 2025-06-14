//
//  HomeView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct HomeView: View {
    @Environment(LocationStore.self) private var locationStore
    
    private func handleOnAppear() {
        locationStore.startLocationUpdates()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DateTimeView()
            WeatherView()
            MapView()
        }
        .onAppear(perform: handleOnAppear)
    }
}

#Preview {
    let locationStore = LocationStore()
    return HomeView()
        .environment(locationStore)
        .environment(WeatherStore(locationStore: locationStore))
}
