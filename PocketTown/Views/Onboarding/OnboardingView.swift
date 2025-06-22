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
            Text("app.title")
                .font(.title)
                .foregroundStyle(.textPrimary)
            VStack(alignment: .leading, spacing: 12) {
                Text("onboarding.description.main")
                Text("onboarding.description.location")
                Text("onboarding.description.radius")
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
        Button("onboarding.button.start") {
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
