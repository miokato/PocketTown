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
    
    private func savePin() {
        if let selectedPin = selectedPin {
            updatePin(selectedPin, note: note)
        } else {
            guard let coordinate = locationStore.selectedLocation else { return }
            addPinWithTitle(title, note: note, coordiante: coordinate)
        }
        dismiss()
    }
    
    private func updatePin(_ pin: MapPin, note: String) {
        pin.note = note
    }
    
    private func addPinWithTitle(_ title: String, note: String, coordiante: CLLocationCoordinate2D) {
        let pin = MapPin(
            title: title,
            note: note,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        mapPinStore.addPin(pin, withContext: modelContext)
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
    private var publicationToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Toggle("公開する", isOn: $togglePublication)
            }
            Text("公開すると同じアプリを利用しているすべてのユーザーが閲覧できます。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onChange(of: togglePublication, handleTogglePublication)
    }
    
    @ViewBuilder
    private var titleTextField: some View {
        VStack(alignment: .leading) {
            Text("mapsheet.label.title")
                .font(.headline)
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
            Text("説明")
            TextField(
                "場所の説明を入力",
                text: $note,
                prompt: Text("場所の説明を入力")
            )
            .textFieldStyle(.roundedBorder)
            .focused($isTitleFieldFocused)
        }
    }
    
    @ViewBuilder
    private var coordinateView: some View {
        VStack(alignment: .leading) {
            Text("mapsheet.label.coordinates")
                .font(.headline)
            HStack {
                Image(systemName: "location")
                Text("mapsheet.label.latitude") + Text(": \(coordinate.latitude, format: .number.precision(.fractionLength(6)))")
                Text("mapsheet.label.longitude") + Text(": \(coordinate.longitude, format: .number.precision(.fractionLength(6)))")
            }
        }
        .font(.caption)
        .foregroundColor(.primary)
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
