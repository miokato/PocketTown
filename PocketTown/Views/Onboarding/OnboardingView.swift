//
//  OnboardingView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var text = ""
    
    private func handleStartButtonTapped() {
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("まちポケット")
                .font(.title)
            Text("まちポケットは自分の家の半径1km圏内の地図に、お気に入りのお店や場所を登録するアプリです。現在位置を取得して、ホームに設定してください。アプリに表示されている青い円が半径1km圏内を表しています。")
                .font(.body)
            Button("はじめる") {
                handleStartButtonTapped()
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background(Material.regular, in: RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
}
