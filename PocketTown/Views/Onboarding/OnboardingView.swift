//
//  OnboardingView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("doneOnboarding") private var doneOnboarding = false
    @State private var text = ""
    
    private func handleStartButtonTapped() {
        dismiss()
    }
    
    private func handleAppear() {
        doneOnboarding = true
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("まちポケット")
                .font(.title)
                .foregroundStyle(.textPrimary)
            VStack(alignment: .leading, spacing: 12) {
                Text("まちポケットは自分の家の半径1km圏内の地図に、お気に入りのお店や場所を登録するアプリです。")
                Text("現在位置を取得して、ホームに設定してください。")
                Text("アプリに表示されている青い円が半径1km圏内を表しています。")
            }
            .font(.body)
            .foregroundStyle(.textSecondary)
            startWithCurrentLocationButton
        }
        .padding(.horizontal, 20)
        .onAppear(perform: handleAppear)
    }
    
    @ViewBuilder
    private var startWithCurrentLocationButton: some View {
        Button("はじめる") {
            handleStartButtonTapped()
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Material.regular, in: RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    OnboardingView()
}
