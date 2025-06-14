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
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isShowAddPinModal = false
    
    // MARK: - Private Methods
    
    private func requestLocationPermissionIfNeeded() {
        if locationStore.authorizationStatus == .notDetermined {
            locationStore.requestLocationPermission()
        }
    }
    
    // MARK: - Methods (handler)
    
    private func handleAppear() {
        requestLocationPermissionIfNeeded()
    }
    
    private func handleAddPin(at location: CGPoint, with proxy: MapProxy) {
        if let coordinate = proxy.convert(location, from: .global) {
            locationStore.selectedLocation = coordinate
            isShowAddPinModal = true
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                mapView(proxy: proxy)
                    .gesture(LongPressGesture { location in
                        handleAddPin(at: location, with: proxy)
                    })
            }
        }
        .sheet(isPresented: $isShowAddPinModal, content: {
            MapSheetView()
                .presentationDetents([.medium])
        })
        .onAppear(perform: handleAppear)
    }
    
    // MARK: View builders
    
    @ViewBuilder
    private func mapView(proxy: MapProxy) -> some View {
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
        .ignoresSafeArea(.keyboard)
        .mapControls {
            MapCompass()
                .mapControlVisibility(.visible)
            MapPitchToggle()
                .mapControlVisibility(.visible)
            MapScaleView()
                .mapControlVisibility(.hidden)
            MapUserLocationButton()
                .mapControlVisibility(.visible)
        }
    }
}

#Preview {
    MapView()
        .environment(LocationStore())
        .environment(MapPinStore())
}

