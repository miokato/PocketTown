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
    
    /// アプリ起動時に一度だけ天気を更新
    @State private var isUpdatedWeather: Bool = false
    @State private var isShowOnboarding: Bool = false
    
    private func showOnboardingWithNoAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isShowOnboarding = true
        }
    }
    
    private func handleOnAppear() {
        locationStore.startLocationUpdates()
        showOnboardingWithNoAnimation()
    }

    private func handleChangeLocation() {
        guard !isUpdatedWeather else { return }
        Task {
            await weatherStore.refreshWeather(by: locationStore.currentLocation)
            isUpdatedWeather = true
        }
    }
    
    var body: some View {
        MapView()
            .fullScreenCover(isPresented: $isShowOnboarding, content: {
                OnboardingView()
            })
            .onAppear(perform: handleOnAppear)
            .onChange(of: locationStore.currentLocation, handleChangeLocation)
    }
}

#Preview {
    HomeView()
        .environment(LocationStore())
        .environment(WeatherStore())
        .environment(MapPinStore())
}
