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
    @State private var showLocationAlert = false
    @State private var isShowAddPinModal = false
    
    // MARK: - Private Methods
    
    private func requestLocationPermissionIfNeeded() {
        if locationStore.authorizationStatus == .notDetermined {
            locationStore.requestLocationPermission()
        }
    }
    
    // MARK: - Methods (handler)
    
    private func handleAddPin(at location: CLLocationCoordinate2D) {
        locationStore.selectedLocation = location
        isShowAddPinModal = true
    }
    
    private func handleAppear() {
        requestLocationPermissionIfNeeded()
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
                        handleAddPin(at: coordinate)
                    }
                })
            }
        }
        .sheet(isPresented: $isShowAddPinModal, content: {
            MapSheetView()
                .presentationDetents([.medium])
        })
        .onAppear(perform: handleAppear)
    }
}

#Preview {
    MapView()
        .environment(LocationStore())
        .environment(MapPinStore())
}

