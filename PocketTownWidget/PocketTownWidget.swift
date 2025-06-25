//
//  PocketTownWidget.swift
//  PocketTownWidget
//
//  Created by mio kato on 2025/06/24.
//

import WidgetKit
import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherEntry: TimelineEntry {
    let date: Date
    let coordinate: CLLocationCoordinate2D?
    let weather: Weather
}

struct Provider: TimelineProvider {
    
    let store = UserDefaults(suiteName: "group.com.example.pockettown")!
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            coordinate: .init(latitude: 35, longitude: 135),
            weather: .sample
        )
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(
            date: Date(),
            coordinate: .init(latitude: 35, longitude: 135),
            weather: .sample
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        Task {
            var coordinate: CLLocationCoordinate2D?
            if let location = store.array(forKey: "LastCoordinate") as? [Double],
               location.count == 2 {
                coordinate = .init(latitude: location[0], longitude: location[1])
            }
            
            guard let coordinate = coordinate else { return }
            let weather = try await WeatherService.shared.fetchWeather(
                for: .init(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )

            let entry = WeatherEntry(
                date: .now,
                coordinate: coordinate,
                weather: weather
            )

            
//            let next = Calendar.current.date(byAdding: .minute, value: 1, to: .now)!
//            completion(Timeline(entries: [entry], policy: .after(next)))
            completion(Timeline(entries: [entry], policy: .never))

        }
    }
}

struct PocketTownWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(DateFormatter.monthDay.string(from: entry.date))
                Text(DateFormatter.weekday.string(from: entry.date))
                Text(entry.date, style: .time)
            }
            Spacer()
            VStack(spacing: 8) {
                // 天気アイコン
                Image(systemName: entry.weather.symbolName)
                    .font(.system(size: 30))
                    .foregroundStyle(.tint)
                    .symbolRenderingMode(.multicolor)
                // 天気の説明
                Text(entry.weather.description)
                    .font(.headline)
                // 湿度
                Label("\(Int(entry.weather.humidity * 100))%", systemImage: "humidity")
                    .font(.caption)
            }
        }
    }
}

struct PocketTownWidget: Widget {
    let kind: String = "PocketTownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PocketTownWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PocketTownWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PocketTownWidget()
} timeline: {
    WeatherEntry(date: Date(), coordinate: .init(latitude: 35, longitude: 135), weather: .sample)
}
