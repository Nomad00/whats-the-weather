//
//  Whats_The_WeatherApp.swift
//  Whats The Weather
//
//  Created by Michael Stanziano on 3/28/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct Whats_The_WeatherApp: App {
    static let store = Store(initialState: WhatsTheWeatherFeature.State()) {
        WhatsTheWeatherFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            WhatsTheWeatherView(store: Whats_The_WeatherApp.store)
        }
    }
}
