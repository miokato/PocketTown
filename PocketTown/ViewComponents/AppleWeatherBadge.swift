//
//  AppleWeatherBadge.swift
//  PocketTown
//
//  Created by mio-kato on 2025/07/18.
//

import SwiftUI
import WeatherKit

struct AppleWeatherBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var legalURL: URL?
    @State private var imageUrl: URL?
    
    // MARK: - private method

    private func loadAttribution() async {
        guard let attr = try? await WeatherService.shared.attribution() else {
            return
        }
        legalURL = attr.legalPageURL
        imageUrl = (colorScheme == .dark) ? attr.combinedMarkDarkURL
        : attr.combinedMarkLightURL
    }
    
    // MARK: - body
    
    var body: some View {
        Button {
            if let url = legalURL { UIApplication.shared.open(url) }
        } label: {
            HStack(spacing: 4) {
                if let imageUrl {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            defaultText
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 14)
                        case .failure(_):
                            defaultText
                        @unknown default:
                            defaultText
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Weather data provided by Apple Weather"))
        .task(loadAttribution)
    }
    
    @ViewBuilder
    private var defaultText: some View {
        Text(" Weather")
            .font(.caption2)
    }
}

#Preview {
    AppleWeatherBadge()
}
