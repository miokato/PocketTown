//
//  OnboardingView.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/15.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(LocationStore.self) private var locationStore
    @AppStorage("doneOnboarding") private var doneOnboarding = false
    
    // MARK: - methods
    
    private func handleStartButtonTapped() {
        doneOnboarding = true
        dismiss()
    }
    
    private func handleUpdateButtonTapped() {
        locationStore.updateUserLocation()
        dismiss()
    }
    
    private func handleCancelButtonTapped() {
        dismiss()
    }
    
    private func handleAppear() {}
    
    // MARK: - body
    
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
            if doneOnboarding {
                VStack(spacing: 20) {
                    updateUserLocationButton
                    cancelButton
                }
            } else {
                startButton
            }
        }
        .padding(.horizontal, 20)
        .onAppear(perform: handleAppear)
    }
    
    // MARK: - view buidlers
    
    @ViewBuilder
    private var startButton: some View {
        Button("onboarding.button.start") {
            handleStartButtonTapped()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 44)
        .background(Material.regular, in: RoundedRectangle(cornerRadius: 4))
    }
    
    @ViewBuilder
    private var updateUserLocationButton: some View {
        Button("現在位置でホームを更新") {
            handleUpdateButtonTapped()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 44)
        .background(Material.regular, in: RoundedRectangle(cornerRadius: 4))
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        Button("キャンセル") {
            handleCancelButtonTapped()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 44)
        .background(Material.regular, in: RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    OnboardingView()
        .environment(LocationStore())
}
