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
    
    // MARK: - Date Formatters
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
        return formatter
    }
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
    
    private var monthDayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // 年
            Text(yearFormatter.string(from: currentDate))
                .font(.caption)
                .foregroundColor(.secondary)
            // 月日
            Text(monthDayFormatter.string(from: currentDate))
                .font(.title2)
                .fontWeight(.medium)
            // 曜日
            Text(weekdayFormatter.string(from: currentDate))
                .font(.body)
                .foregroundColor(.secondary)
            Divider()
                .padding(.horizontal)
            // 時刻
            Text(timeFormatter.string(from: currentDate))
                .font(.title)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding()
        .onReceive(timer) { _ in
            currentDate = Date()
        }
    }
}

#Preview {
    DateTimeView()
}
