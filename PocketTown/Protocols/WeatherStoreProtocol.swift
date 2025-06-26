//
//  WeatherStoreProtocol.swift
//  PocketTown
//
//  Created by mio-kato on 2025/06/27.
//

import WeatherKit
import Observation
import CoreLocation
import SwiftUI

@MainActor
protocol WeatherStoreProtocol {
    var weather: Weather? { get set }
    var isLoading: Bool { get set }
    var error: Error? { get set }
    
    func refreshWeather(by location: CLLocation?) async
}

@MainActor @Observable
final class WeatherStoreMock: WeatherStoreProtocol {
    var weather: Weather? = nil
    var isLoading: Bool = false
    var error: Error? = nil
    func refreshWeather(by location: CLLocation?) async {}
}

@MainActor
struct WeatherStoreKey: @preconcurrency EnvironmentKey {
    static let defaultValue: any WeatherStoreProtocol = WeatherStoreMock()
}

extension EnvironmentValues {
    var weatherStore: any WeatherStoreProtocol {
        get { self[WeatherStoreKey.self] }
        set { self[WeatherStoreKey.self] = newValue }
    }
}
