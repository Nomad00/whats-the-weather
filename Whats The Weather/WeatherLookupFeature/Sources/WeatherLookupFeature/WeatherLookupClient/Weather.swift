//
//  Weather.swift
//  
//
//  Created by Michael Stanziano on 4/13/24.
//

import Foundation

// TODO: Don't love this name 🤔 Really don't want to pull in `CoreLocation` though.
/// The latitude & longitude representation of the location to look up the weather for.
public struct LatitudeLongitudePair {
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    let latitude: Double
    let longitude: Double
}

extension LatitudeLongitudePair {
    /// Fun helper to use the location of Apple Park.
    static var applePark: LatitudeLongitudePair = .init(
        latitude: 37.334606,
        longitude: -122.009102
    )
}

/// Data type returned by the ``WeatherLookupClient``.
public struct Weather {
    /// Current temperature.
    let temperature: Double
    /// A short text representation of the current weather.
    let description: String
}

extension Weather {
    /// Helper property providing mock data.
    public static var mock = Self(
        temperature: 42.0,
        description: "Just about right."
    )
}
