//
//  Weather.swift
//  
//
//  Created by Michael Stanziano on 4/13/24.
//

import Foundation

// TODO: Don't love this 🤔
/// The latitude & longitude representation of the location to look up the weather for.
public typealias LatitudeLongitudePair = (Latitude: Double, Longitude: Double)

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
