//
//  DateTimeView.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/14.
//

import SwiftUI

struct DateTimeView: View {
    // MARK: - Properties
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // 年
            Text(DateFormatter.year.string(from: currentDate))
                .font(.caption)
                .foregroundColor(.textSecondary)
            // 月日
            Text(DateFormatter.monthDay.string(from: currentDate))
                .font(.title2)
                .bold()
                .foregroundColor(.textPrimary)
            // 曜日
            Text(DateFormatter.weekday.string(from: currentDate))
                .font(.body)
                .foregroundColor(.textSecondary)
            Divider()
                .frame(width: 120)
                .padding(.horizontal)
            // 時刻
            Text(DateFormatter.time.string(from: currentDate))
                .font(.title2)
                .bold()
                .foregroundColor(.textPrimary)
                .monospacedDigit()
        }
        .padding(.vertical)
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
}

#Preview {
    DateTimeView()
}
