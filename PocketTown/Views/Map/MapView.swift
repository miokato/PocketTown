//
//  MapView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(LocationStore.self) private var locationStore
    @Query var mapPins: [MapPin]
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedPin: MapPin?
    @State private var isShowAddPinModal = false
    
    // MARK: - Private Methods
    
    private func requestLocationPermissionIfNeeded() {
        if locationStore.authorizationStatus == .notDetermined {
            locationStore.requestLocationPermission()
        }
    }
    
    private func zoomInCameraToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut) {
            position = .camera(.init(
                centerCoordinate: coordinate,
                distance: 1500)
            )
        }
    }
    
    // MARK: - Methods (handler)
    
    private func handleAppear() {
        requestLocationPermissionIfNeeded()
    }
    
    private func handleAddPin(at location: CGPoint, with proxy: MapProxy) {
        selectedPin = nil
        if let coordinate = proxy.convert(location, from: .global) {
            zoomInCameraToCoordinate(coordinate)
            locationStore.selectedLocation = coordinate
            isShowAddPinModal = true
        }
    }
    
    private func handleTapSelectedPin() {
        guard let selectedPin = selectedPin else { return }
        zoomInCameraToCoordinate(selectedPin.coordinate)
        isShowAddPinModal = true
    }
    
    private func handleIsShowAddPinModal() {
        guard !isShowAddPinModal else { return }
        withAnimation {
            selectedPin = nil
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
            MapSheetView(selectedPin: selectedPin)
                .presentationDetents([.medium])
        })
        .onAppear(perform: handleAppear)
        .onChange(of: selectedPin, handleTapSelectedPin)
        .onChange(of: isShowAddPinModal, handleIsShowAddPinModal)
    }
    
    // MARK: View builders
    
    @ViewBuilder
    private func mapView(proxy: MapProxy) -> some View {
        Map(position: $position, selection: $selectedPin) {
            UserAnnotation()
            
            if let location = locationStore.currentLocation {
                MapCircle(center: location.coordinate, radius: 1000)
                    .foregroundStyle(.black.opacity(0.05))
                    .stroke(.blue, lineWidth: 1)
            }
            
            ForEach(mapPins) { pin in
                Marker(pin.title, coordinate: pin.coordinate)
                    .tag(pin)
            }
        }
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
        .mapFeatureSelectionContent(content: { _ in
        })
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                WeatherView()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MapView()
        .environment(LocationStore())
        .environment(WeatherStore())
}

