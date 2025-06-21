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
        Text("PublicMapModalView")
    }
}

#Preview {
    PublicPinModalView(selectedPin: .makeSample(.init(latitude: 0, longitude: 0)))
}
