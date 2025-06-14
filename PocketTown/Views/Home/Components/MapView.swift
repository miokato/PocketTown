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
    @Environment(MapPinStore.self) private var mapPinStore
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
    
    private func handleAppear() {
        requestLocationPermissionIfNeeded()
    }
    
    private func handleLocationError() {
        guard let _ = locationStore.locationError else {
            return
        }
        showLocationAlert = true
    }
    
    private func isLocationDenied() -> Bool {
        locationStore.authorizationStatus == .denied || locationStore.authorizationStatus == .restricted
    }
    
    private func addPin(at coordinate: CLLocationCoordinate2D) {
        let pin = MapPin(
            title: "ピン",
            description: "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        mapPinStore.addPin(pin)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: $position) {
                    UserAnnotation()
                    
                    if let location = locationStore.currentLocation {
                        MapCircle(center: location.coordinate, radius: 1000)
                            .foregroundStyle(.blue.opacity(0.1))
                            .stroke(.blue, lineWidth: 1)
                    }
                    
                    ForEach(mapPinStore.pins) { pin in
                        Marker(pin.title, coordinate: pin.coordinate)
                    }
                }
                .gesture(LongPressGesture { location in
                    if let coordinate = proxy.convert(location, from: .global) {
                        addPin(at: coordinate)
                    }
                })
            }
            if isLocationDenied() {
                locationDeniedOverlay
            }
        }
        .alert(String(localized: "map.error.title"), isPresented: $showLocationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(locationStore.locationError?.localizedDescription ?? String(localized: "map.error.message"))
        }
        .onAppear(perform: handleAppear)
        .onChange(of: locationStore.locationError, handleLocationError)
        .onChange(of: locationStore.currentLocation, handleChangeLocation)
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private var locationDeniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(String(localized: "map.permission.title"))
                .font(.headline)
            
            Text(String(localized: "map.permission.message"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(String(localized: "map.button.settings")) {
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
        .environment(MapPinStore())
}

