//
//  PocketView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI
import SwiftData

struct PocketView: View {
    @Query var mapPins: [MapPin]
    
    var body: some View {
        List(mapPins) { pin in
            Text("\(pin.title)")
        }
    }
}

#Preview {
    PocketView()
}
