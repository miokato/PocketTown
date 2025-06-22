//
//  PublicMapModalView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/22.
//

import SwiftUI

struct PublicPinModalView: View {
    let selectedPin: MapPin?
    
    var body: some View {
        Form {
            if let pin = selectedPin {
                Section {
                    Text(pin.title)
                    Text(pin.note)
                }
                .foregroundStyle(.textPrimary)
                Section {
                    coordinateView(pin: pin)
                } header: {
                    Text("mapsheet.label.coordinates")
                }
            } else {
                Text("publicpin.error.notfound")
            }
        }
    }
    
    @ViewBuilder
    private func coordinateView(pin: MapPin) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location")
                Text("mapsheet.label.latitude") + Text(": \(pin.latitude, format: .number.precision(.fractionLength(6)))")
                Text("mapsheet.label.longitude") + Text(": \(pin.longitude, format: .number.precision(.fractionLength(6)))")
            }
        }
        .font(.caption)
        .foregroundColor(.textPrimary)
    }
}

#Preview {
    PublicPinModalView(
        selectedPin: MapPin(
            title: "テストピン",
            note: "テストノート",
            latitude: 35.0,
            longitude: 135.0,
            isPublic: false
        )
    )
}
