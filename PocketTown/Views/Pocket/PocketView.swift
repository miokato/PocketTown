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
        NavigationStack {
            List(mapPins) { pin in
                NavigationLink {
                    if pin.isPublic {
                        MapPinModal(selectedPin: pin)
                    } else {
                        MapPinModal(selectedPin: pin)
                    }
                    
                } label: {
                    Text("\(pin.title)")
                }
            }
        }
    }
}

#Preview {
    PocketView()
}
