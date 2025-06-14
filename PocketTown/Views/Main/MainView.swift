//
//  MainView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct MainView: View {
    @State private var locationStore = LocationStore()
    
    var body: some View {
        HomeView()
            .environment(locationStore)
    }
}

#Preview {
    MainView()
}
