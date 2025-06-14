//
//  HomeView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            DateTimeView()
            WeatherView()
            MapView()
        }
    }
}

#Preview {
    HomeView()
        .environment(LocationStore())
}
