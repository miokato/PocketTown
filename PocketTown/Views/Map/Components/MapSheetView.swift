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
    @State private var isShowDeleteAlert = false
    @FocusState private var isTitleFieldFocused: Bool
    
    private var coordinate: CLLocationCoordinate2D {
        locationStore.selectedLocation ?? .init(latitude: 0, longitude: 0)
    }
    
    // MARK: - Private Methods
    
    private func validateText(_ text: String) -> String? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            showEmptyTitleAlert = true
            return nil
        }
        return trimmedTitle
    }
    
    private func savePin() {
        guard let validTitle = validateText(title) else { return }
        
        if let selectedPin = selectedPin {
            editPin(selectedPin, withTitle: validTitle)
        } else {
            guard let coordinate = locationStore.selectedLocation else { return }
            addPinWithTitle(validTitle, coordiante: coordinate)
        }
        dismiss()
    }
    
    private func editPin(_ pin: MapPin, withTitle title: String) {
        pin.title = title
    }
    
    private func addPinWithTitle(_ title: String, coordiante: CLLocationCoordinate2D) {
        let pin = MapPin(
            title: title,
            description: "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        mapPinStore.addPin(pin, withContext: modelContext)
    }
    
    private func deletePin() {
        guard let selectedPin = selectedPin else { return }
        mapPinStore.removePin(selectedPin, withContext: modelContext)
    }
    
    private func updatePin() {
        guard let selectedPin = selectedPin else { return }
        title = selectedPin.title
    }
    
    private func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    private func handleAppear() {
        updatePin()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                titleView
                coordinateView
                saveButton
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
                    Button("削除", role: .destructive, action: showDeleteAlert)
                        .foregroundStyle(Color.red)
                }
            }
        }
        .alert("mapsheet.alert.title", isPresented: $showEmptyTitleAlert) {
            Button("OK") {
                isTitleFieldFocused = true
            }
        }
        .alert("削除しますか", isPresented: $isShowDeleteAlert) {
            HStack {
                Button("キャンセル", role: .cancel) {
                    isShowDeleteAlert = false
                }
                Button("削除", role: .destructive) {
                    deletePin()
                    dismiss()
                }
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
    
    @ViewBuilder
    private var saveButton: some View {
        Button("mapsheet.button.save", action: savePin)
            .fontWeight(.semibold)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

#Preview {
    MapSheetView(selectedPin: nil)
        .environment(MapPinStore())
        .environment(LocationStore())
}
