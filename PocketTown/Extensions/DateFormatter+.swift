//
//  DateFormatter+.swift
//  PocketTown
//
//  Created by mio kato on 2025/06/24.
//

import SwiftUI

extension DateFormatter {
    static var date: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }
    
    static var time: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter
    }
    
    static var year: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
    
    static var monthDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
    
    static var weekday: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: Locale.current)
        formatter.locale = Locale.current
        return formatter
    }
}
