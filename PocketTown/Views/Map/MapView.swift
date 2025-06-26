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
    @Environment(MapPinStore.self) private var mapPinStore
    @Query var mapPins: [MapPin]
    
    @State private var position: MapCameraPosition = .automatic
    @State private var tappedPin: MapPin?
    @State private var selectedPin: MapPin?
    @State private var selection: MapSelection<MapPlace>?
    @State private var isShowAddPinModal = false
    @State private var isShowPublicPinModal = false

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
        if let userLocation = locationStore.savedUserLocation {
            mapPinStore.fetchPublicPins(around: userLocation)
        }
    }
    
    private func handleAddPin(at location: CGPoint, with proxy: MapProxy) {
        selectedPin = nil
        if let coordinate = proxy.convert(location, from: .global) {
            tappedPin = MapPin.makeSample(coordinate)
            zoomInCameraToCoordinate(coordinate)
            locationStore.selectedLocation = coordinate
            isShowAddPinModal = true
        }
    }
    
    private func handleTapSelection() {
        guard let mapPlace = selection?.value else { return }
        switch mapPlace {
        case .pin(let pin):
            selectedPin = pin
            zoomInCameraToCoordinate(pin.coordinate)
            isShowAddPinModal = true
        case .publicPin(let pin):
            selectedPin = pin
            zoomInCameraToCoordinate(pin.coordinate)
            isShowPublicPinModal = true
        case .poi(let item):
            break
        }
    }
    
    private func handleIsShowAddPinModal() {
        guard !isShowAddPinModal else { return }
        withAnimation {
            tappedPin = nil
            selectedPin = nil
        }
    }
    
    private func handleIsShowPublicPinModal() {
        guard !isShowPublicPinModal else { return }
        withAnimation {
            tappedPin = nil
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
            MapPinModal(selectedPin: selectedPin)
                .presentationDetents([.medium])
        })
        .sheet(isPresented: $isShowPublicPinModal, content: {
            PublicPinModalView(selectedPin: selectedPin)
                .presentationDetents([.medium])
        })
        .onAppear(perform: handleAppear)
        .onChange(of: selection, handleTapSelection)
        .onChange(of: isShowAddPinModal, handleIsShowAddPinModal)
        .onChange(of: isShowPublicPinModal, handleIsShowPublicPinModal)
    }
    
    // MARK: View builders
    
    @ViewBuilder
    private func mapView(proxy: MapProxy) -> some View {
        Map(position: $position, selection: $selection) {
            UserAnnotation()
            
            if let location = locationStore.savedUserLocation {
                MapCircle(center: location.coordinate, radius: 1000)
                    .foregroundStyle(.black.opacity(0.05))
                    .stroke(.blue, lineWidth: 1)
            }
            
            if let pin = tappedPin {
                Marker(pin.title, coordinate: pin.coordinate)
                    .tag(MapSelection(MapPlace.pin(pin)))
            }
            
            /// プライベートで自分が置いているピン
            ForEach(mapPins) { pin in
                Marker(pin.title, coordinate: pin.coordinate)
                    .tag(MapSelection(MapPlace.pin(pin)))
                    .tint(.primaryAccent)
            }
            
            /// Publicに公開されているピン
            ForEach(mapPinStore.publicMapPins) { pin in
                Marker(pin.title, coordinate: pin.coordinate)
                    .tag(MapSelection(MapPlace.publicPin(pin)))
                    .tint(.tertiaryAccent)
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
        .mapFeatureSelectionAccessory(.callout)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MapView()
        .environment(LocationStore())
        .environment(\.weatherStore, WeatherStoreMock())
        .environment(MapPinStore())
}

