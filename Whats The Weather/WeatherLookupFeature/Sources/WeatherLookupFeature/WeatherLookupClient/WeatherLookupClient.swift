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
    
    /// A ``WeatherLookupClient`` which always returns mock data.
    public static var previewValue: WeatherLookupClient = Self(
        lookupWeatherFor: { _ in
            Weather.mock
        }
    )

    /// A ``WeatherLookupClient`` which waits 3 seconds before returning a result.
    ///
    /// This is useful for exercising loading and refreshing in previews and tests.
    public static var loadingValue: WeatherLookupClient = Self(
        lookupWeatherFor: { _ in
            let delay = 3
            if #available(iOS 16.0, *) {
                try await Task.sleep(for: .seconds(delay))
            } else {
                // Fallback on earlier versions
                try await Task.sleep(nanoseconds: .init(delay * 1_000_000_000))
            }
            return Weather.mock
        }
    )
}
