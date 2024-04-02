//
//  LocationLookupClient.swift
//
//
//  Created by Michael Stanziano on 4/1/24.
//

import ComposableArchitecture
import CoreLocation
import Foundation


extension DependencyValues {
    public var locationLookupClient: LocationLookupClient {
        get { self[LocationLookupClient.self] }
        set { self[LocationLookupClient.self] = newValue }
    }
}

public struct LocationLookupClient {
    public var lookupCurrentLocation: @Sendable () async -> CLLocation
}

private extension CLLocation {
    /// Fun helper to use the location of Apple Park.
    static var applePark: CLLocation = .init(
        latitude: 37.334606,
        longitude: -122.009102
    )
}

extension LocationLookupClient: DependencyKey {
    // TODO: Build the live client.
    public static var liveValue: LocationLookupClient = Self(
        lookupCurrentLocation: {
            .applePark
        }
    )
}

extension LocationLookupClient: TestDependencyKey {
    public static var testValue: LocationLookupClient = Self(
        lookupCurrentLocation: unimplemented("WeatherLookupClient.lookupCurrentLocation")
    )
    
    public static var previewValue: LocationLookupClient = Self(
        lookupCurrentLocation: {
                .applePark
        }
    )
}
