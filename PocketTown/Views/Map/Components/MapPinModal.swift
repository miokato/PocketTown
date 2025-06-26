//
//  MapPinModal.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/14.
//

import SwiftUI
import SwiftData
import MapKit

struct MapPinModal: View {
    let selectedPin: MapPin?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.mapPinStore) private var mapPinStore
    @Environment(LocationStore.self) private var locationStore
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var note = ""
    @State private var showEmptyTitleAlert = false
    @State private var isShowDeleteAlert = false
    @State private var togglePublication = false
    @FocusState private var isTitleFieldFocused: Bool
    
    private var enableTitleEdit: Bool {
        selectedPin == nil
    }
    
    private var coordinate: CLLocationCoordinate2D {
        locationStore.selectedLocation ?? .init(latitude: 0, longitude: 0)
    }
    
    // MARK: - Private Methods
    
    /// ピンが存在しなければ作成、存在すれば更新
    private func upsertPin() {
        if let selectedPin = selectedPin {
            updatePin(selectedPin, note: note)
        } else {
            guard let coordinate = locationStore.selectedLocation else { return }
            addPin(title: title, note: note, coordiante: coordinate)
        }
        dismiss()
    }
    
    /// ピンの情報を更新
    private func updatePin(_ pin: MapPin, note: String) {
        pin.note = note
    }
    
    private func addPin(title: String, note: String, coordiante: CLLocationCoordinate2D) {
        let pin = MapPin(
            title: title,
            note: note,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isPublic: togglePublication
        )
        mapPinStore.addPin(pin, withContext: modelContext, isPublic: togglePublication)
    }
    
    private func removePin() {
        guard let selectedPin = selectedPin else { return }
        mapPinStore.removePin(selectedPin, withContext: modelContext)
    }
    
    /// 保存済みのピンが選択されたとき表示を更新
    private func updateTextField() {
        guard let selectedPin = selectedPin else { return }
        title = selectedPin.title
        note = selectedPin.note
        locationStore.selectedLocation = selectedPin.coordinate
    }
    
    private func updateTogglePublication() {
        guard let selectedPin = selectedPin else { return }
        if selectedPin.publicRecordName != nil {
            togglePublication = true
        }
    }
    
    private func showDeleteAlert() {
        isShowDeleteAlert = true
    }
    
    // MARK: - methods (handler)
    
    private func handleAppear() {
        updateTextField()
        updateTogglePublication()
    }
    
    private func handleTogglePublication() {
        guard let pin = selectedPin else { return }
        Task {
            await mapPinStore.togglePublic(pin: pin, makePublic: togglePublication)
            log("\(togglePublication)", with: .debug)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    editView
                    coordinateView
                }
                saveButton
                    .buttonStyle(.borderedProminent)
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
                    Button("mapsheet.button.delete", role: .destructive, action: showDeleteAlert)
                        .foregroundStyle(Color.red)
                }
            }
        }
        .alert("mapsheet.alert.title", isPresented: $showEmptyTitleAlert) {
            Button("OK") {
                isTitleFieldFocused = true
            }
        }
        .alert("mapsheet.alert.delete", isPresented: $isShowDeleteAlert) {
            HStack {
                Button("mapsheet.button.cancel", role: .cancel) {
                    isShowDeleteAlert = false
                }
                Button("mapsheet.button.delete", role: .destructive) {
                    removePin()
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - View builders
    
    @ViewBuilder
    private var editView: some View {
        titleTextField
        noteTextField
        publicationToggle
    }
    
    @ViewBuilder
    private var titleTextField: some View {
        VStack(alignment: .leading) {
            Text("mapsheet.label.title")
                .font(.body)
                .foregroundStyle(.textPrimary)
            TextField(
                "mapsheet.placeholder.title",
                text: $title,
                prompt: Text("mapsheet.placeholder.title")
            )
            .textFieldStyle(.roundedBorder)
            .focused($isTitleFieldFocused)
            .disabled(!enableTitleEdit)
        }
    }
    
    @ViewBuilder
    private var noteTextField: some View {
        VStack(alignment: .leading) {
            Text("mapsheet.label.note")
                .font(.body)
                .foregroundStyle(.textPrimary)
            TextField(
                "mapsheet.placeholder.note",
                text: $note,
                prompt: Text("mapsheet.placeholder.note")
            )
            .textFieldStyle(.roundedBorder)
            .focused($isTitleFieldFocused)
        }
    }
    
    @ViewBuilder
    private var publicationToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Toggle("mapsheet.label.public", isOn: $togglePublication)
                    .foregroundStyle(.textPrimary)
            }
            Text("mapsheet.label.public.description")
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .onChange(of: togglePublication, handleTogglePublication)
    }
    
    @ViewBuilder
    private var coordinateView: some View {
        VStack(alignment: .leading) {
            Text("mapsheet.label.coordinates")
                .font(.body)
                .foregroundStyle(.textPrimary)
            HStack {
                Image(systemName: "location")
                Text("mapsheet.label.latitude") + Text(": \(coordinate.latitude, format: .number.precision(.fractionLength(6)))")
                Text("mapsheet.label.longitude") + Text(": \(coordinate.longitude, format: .number.precision(.fractionLength(6)))")
            }
        }
        .font(.caption)
        .foregroundColor(.textPrimary)
    }
    
    @ViewBuilder
    private var saveButton: some View {
        Button("mapsheet.button.save", action: upsertPin)
            .fontWeight(.semibold)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

#Preview {
    MapPinModal(selectedPin: nil)
        .environment(\.mapPinStore, MapPinStoreMock())
        .environment(LocationStore())
}
