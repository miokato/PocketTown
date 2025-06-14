//
//  HomeView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct HomeView: View {
    @Environment(LocationStore.self) private var locationStore
    @Environment(WeatherStore.self) private var weatherStore
    
    private func handleOnAppear() {
        locationStore.startLocationUpdates()
    }
    
    private func handleChangeLocation() {
        Task {
            await weatherStore.refreshWeather(by: locationStore.currentLocation)
        }
    }
    
    var body: some View {
        MapView()
            .onAppear(perform: handleOnAppear)
            .onChange(of: locationStore.currentLocation, handleChangeLocation)
    }
}

#Preview {
    HomeView()
        .environment(LocationStore())
        .environment(WeatherStore())
}
