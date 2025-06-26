//
//  MainView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct MainView: View {
    @Environment(LocationStore.self) private var locationStore
    @Environment(\.weatherStore.self) private var weatherStore
    @Environment(MapPinStore.self) private var mapPinStore
    @Environment(\.scenePhase) var scenePhase
    
    /// アプリ起動時に一度だけ天気を更新
    @State private var isUpdatedWeather: Bool = false
    @State private var isShowOnboarding: Bool = false
    @AppStorage("doneOnboarding") private var doneOnboarding = false
    
    
    private func handleOnAppear() {
        locationStore.startLocationUpdates()
        
        if !doneOnboarding {
            isShowOnboarding = true
        }
    }
    
    private func updatePublicPins() {
        guard let userLocation = locationStore.savedUserLocation else { return }
        mapPinStore.fetchPublicPins(around: userLocation)
    }

    private func handleChangeLocation() {
        guard !isUpdatedWeather else { return }
        Task {
            await weatherStore.refreshWeather(by: locationStore.currentLocation)
            isUpdatedWeather = true
        }
    }
    
    /// フォアグラウンド遷移時にPublicなピンを取得
    private func handleUpdatePhase() {
        guard scenePhase == .active else { return }
        updatePublicPins()
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                Tab("Map", systemImage: "map") {
                    MapView()
                }
                Tab("Pocket", systemImage: "list.bullet") {
                    PocketView()
                }

            }
            .fullScreenCover(isPresented: $isShowOnboarding, content: {
                OnboardingView()
            })
            .onAppear(perform: handleOnAppear)
            .onChange(of: locationStore.currentLocation, handleChangeLocation)
            .onChange(of: scenePhase, handleUpdatePhase)
            .navigationTitle("app.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        updatePublicPins()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowOnboarding = true
                    } label: {
                        Image(systemName: "note")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
            .environment(LocationStore())
            .environment(\.weatherStore, WeatherStoreMock())
            .environment(MapPinStore())
    }
}
