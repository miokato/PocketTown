//
//  MapPlace.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/21.
//

import SwiftUI
import MapKit

enum MapPlace: Hashable {
    case pin(MapPin)
    case poi(MKMapItem)
}

struct MapItemView: View {
    var body: some View {
        Text("MapItem")
    }
}

