//
//  PocketView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

struct PocketView: View {
    @Environment(MapPinStore.self) private var store
    var body: some View {
        List(store.pins) { pin in
            Text("\(pin.title)")
        }
    }
}

#Preview {
    PocketView()
        .environment(MapPinStore())
}
