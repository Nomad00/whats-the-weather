//
//  WeatherLookupFeature.swift
//
//
//  Created by Michael Stanziano on 4/1/24.
//

/// Data type returned by the ``WeatherLookupClient``.
public struct Weather {
    /// Current temperature.
    let temperature: Double
    /// A short text representation of the current weather.
    let description: String
}

extension Weather {
    /// Helper property providing mock data.
    static var mock = Self(
        temperature: 42.0,
        description: "Just about right."
    )
}
