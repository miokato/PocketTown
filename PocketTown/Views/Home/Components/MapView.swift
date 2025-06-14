//
//  MapView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationStore.self) private var locationStore
    @State private var position = MapCameraPosition.region(.init(center: .init(latitude: 35, longitude: 139), span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    @State private var isLocationUpdated = false
    @State private var showLocationAlert = false
    
    // MARK: - Private Methods
    private func requestLocationPermissionIfNeeded() {
        if locationStore.authorizationStatus == .notDetermined {
            locationStore.requestLocationPermission()
        }
    }
    
    private func updateRegion(with location: CLLocation) {
        let coordinate = location.coordinate
        let span = calculateSpanForRadius(1000, at: coordinate)
        
        withAnimation {
            let position = MapCameraPosition.region(.init(center: coordinate, span: span))
            self.position = position
        }
        
        if !isLocationUpdated {
            isLocationUpdated = true
        }
    }
    
    private func calculateSpanForRadius(_ radius: CLLocationDistance, at coordinate: CLLocationCoordinate2D) -> MKCoordinateSpan {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        return region.span
    }
    
    private func handleChangeLocation() {
        guard let location = locationStore.currentLocation else { return }
        updateRegion(with: location)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Map(position: $position)
            if locationStore.authorizationStatus == .denied || locationStore.authorizationStatus == .restricted {
                locationDeniedOverlay
            }
        }
        .alert("位置情報エラー", isPresented: $showLocationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(locationStore.locationError?.localizedDescription ?? "位置情報の取得中にエラーが発生しました")
        }
        .onAppear {
            requestLocationPermissionIfNeeded()
        }
        .onChange(of: locationStore.locationError) { _, newError in
            showLocationAlert = newError != nil
        }
        .onChange(of: locationStore.currentLocation, handleChangeLocation)
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private var locationDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("位置情報へのアクセスが必要です")
                .font(.headline)
            
            Text("設定アプリから位置情報の使用を許可してください")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("設定を開く") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .padding()
    }
}

#Preview {
    MapView()
        .environment(LocationStore())
}
