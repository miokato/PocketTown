//
//  MapSheetView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/14.
//

import SwiftUI
import SwiftData
import MapKit

struct MapSheetView: View {
    let selectedPin: MapPin?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MapPinStore.self) private var mapPinStore
    @Environment(LocationStore.self) private var locationStore
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var showEmptyTitleAlert = false
    @FocusState private var isTitleFieldFocused: Bool
    
    private var coordinate: CLLocationCoordinate2D {
        locationStore.selectedLocation ?? .init(latitude: 0, longitude: 0)
    }
    
    // MARK: - Private Methods
    
    private func savePin() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            showEmptyTitleAlert = true
            return
        }
        guard let coordinate = locationStore.selectedLocation else { return }
        
        let pin = MapPin(
            title: trimmedTitle,
            description: "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
       mapPinStore.addPin(pin, withContext: modelContext)
        dismiss()
    }
    
    private func updatePin() {
        guard let selectedPin = selectedPin else { return }
        
        title = selectedPin.title
    }
    
    private func handleAppear() {
        updatePin()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                titleView
                coordinateView
                Spacer()
            }
            .onAppear(perform: handleAppear)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("mapsheet.button.cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("mapsheet.button.save") {
                        savePin()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert("mapsheet.alert.title", isPresented: $showEmptyTitleAlert) {
            Button("OK") {
                isTitleFieldFocused = true
            }
        }
    }
    
    // MARK: - View builders
    
    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("mapsheet.label.title")
                .font(.headline)
            
            TextField(
                "mapsheet.placeholder.title",
                text: $title,
                prompt: Text("mapsheet.placeholder.title")
            )
            .textFieldStyle(.roundedBorder)
            .focused($isTitleFieldFocused)
            .onSubmit(savePin)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var coordinateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("mapsheet.label.coordinates")
                .font(.headline)
            HStack {
                Image(systemName: "location")
                Text("mapsheet.label.latitude") + Text(": \(coordinate.latitude, format: .number.precision(.fractionLength(6)))")
                Text("mapsheet.label.longitude") + Text(": \(coordinate.longitude, format: .number.precision(.fractionLength(6)))")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    MapSheetView(selectedPin: nil)
        .environment(MapPinStore())
        .environment(LocationStore())
}
