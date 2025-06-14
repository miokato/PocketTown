//
//  MapSheetView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/14.
//

import SwiftUI
import MapKit

struct MapSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MapPinStore.self) private var mapPinStore
    
    let coordinate: CLLocationCoordinate2D
    
    @State private var title = ""
    @State private var showEmptyTitleAlert = false
    @FocusState private var isTitleFieldFocused: Bool
    
    // MARK: - Private Methods
    
    private func savePin() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            showEmptyTitleAlert = true
            return
        }
        
        let pin = MapPin(
            title: trimmedTitle,
            description: "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        mapPinStore.addPin(pin)
        dismiss()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("mapsheet.label.title", comment: "Title label for the map pin")
                        .font(.headline)
                    
                    TextField("mapsheet.placeholder.title", text: $title, prompt: Text("mapsheet.placeholder.title", comment: "Placeholder for pin title"))
                        .textFieldStyle(.roundedBorder)
                        .focused($isTitleFieldFocused)
                        .onSubmit {
                            savePin()
                        }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("mapsheet.label.coordinates", comment: "Coordinates label")
                        .font(.headline)
                    
                    HStack {
                        Label {
                            Text("mapsheet.label.latitude", comment: "Latitude label") + Text(": \(coordinate.latitude, format: .number.precision(.fractionLength(6)))")
                        } icon: {
                            Image(systemName: "location")
                        }
                        .font(.caption)
                        
                        Spacer()
                        
                        Label {
                            Text("mapsheet.label.longitude", comment: "Longitude label") + Text(": \(coordinate.longitude, format: .number.precision(.fractionLength(6)))")
                        } icon: {
                            Image(systemName: "location")
                        }
                        .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("mapsheet.title")
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
}

#Preview {
    MapSheetView(coordinate: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125))
        .environment(MapPinStore())
}
