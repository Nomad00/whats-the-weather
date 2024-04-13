//
//  WeatherLookupClient.swift
//
//
//  Created by Michael Stanziano on 4/1/24.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    public var weatherLookupClient: WeatherLookupClient {
        get { self[WeatherLookupClient.self] }
        set { self[WeatherLookupClient.self] = newValue }
    }
}

public struct WeatherLookupClient {
    public var lookupWeatherFor: @Sendable (LatitudeLongitudePair) async throws -> Weather
}

extension WeatherLookupClient: DependencyKey {
    // TODO: Build live client.
    public static var liveValue: WeatherLookupClient = Self(
        lookupWeatherFor: { _ in
            Weather.mock
        }
    )
}

extension WeatherLookupClient: TestDependencyKey {
    public static var testValue: WeatherLookupClient = Self(
        lookupWeatherFor: unimplemented("WeatherLookupClient.lookupWeatherFor")
    )
    
    public static var previewValue: WeatherLookupClient = Self(
        lookupWeatherFor: { _ in
            Weather.mock
        }
    )
}
