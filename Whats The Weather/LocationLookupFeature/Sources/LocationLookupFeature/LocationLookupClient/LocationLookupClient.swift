//
//  LocationLookupClient.swift
//
//
//  Created by Michael Stanziano on 4/1/24.
//

import ComposableArchitecture
import CoreLocation
import Foundation
import MapKit

public struct AddressSearch {
    public var results: [Address]

    public struct Address: Identifiable {
        public let id: UUID
        public let title: String
        public let latitude: Double
        public let longitude: Double
    }
}

#if DEBUG
extension AddressSearch {
    public static var cupertinoSearch: AddressSearch = Self(
        results: [
            .init(
                id: UUID(0),
                title: "Cupertino, CA",
                latitude: CLLocation.applePark.coordinate.latitude,
                longitude: CLLocation.applePark.coordinate.longitude
            )
        ]
    )
}
#endif


extension DependencyValues {
    public var locationLookupClient: LocationLookupClient {
        get { self[LocationLookupClient.self] }
        set { self[LocationLookupClient.self] = newValue }
    }
}

public struct LocationLookupClient {
    public var lookupCurrentLocation: @Sendable () async throws -> CLLocation
    public var search: @Sendable (String) async throws -> AddressSearch
}

// TOOD: Debug gate.
// #if DEBUG
private extension CLLocation {
    /// Fun helper to use the location of Apple Park.
    static var applePark: CLLocation = .init(
        latitude: 37.334606,
        longitude: -122.009102
    )
}
// #endif

extension LocationLookupClient: DependencyKey {
    public static var liveValue: LocationLookupClient = Self(
        lookupCurrentLocation: {
            // TODO: Build the live client.
            .applePark
        },
        search: { searchString in
            @Dependency(\.uuid) var uuid

            guard !searchString.isEmpty else { return .init(results: []) }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString
            let localSearchResponse = try await MKLocalSearch(request: request).start()
            let addresses = localSearchResponse.mapItems.map {
                AddressSearch.Address(
                    id: uuid(), // TODO: Use $0.placemark.region?.identifier?
                    title: $0.placemark.title ?? "", // TODO: What to do when these are `nil`?
                    latitude: $0.placemark.coordinate.latitude,
                    longitude: $0.placemark.coordinate.longitude
                )
            }

            return AddressSearch(results: addresses)
        }
    )
}

extension LocationLookupClient: TestDependencyKey {
    public static var testValue: LocationLookupClient = Self(
        lookupCurrentLocation: unimplemented("LocationLookupClient.lookupCurrentLocation"),
        search: unimplemented("LocationLookupClient.search")
    )
    
    public static var previewValue: LocationLookupClient = Self(
        lookupCurrentLocation: {
            .applePark
        },
        search: { _ in
            .cupertinoSearch
        }
    )

    public static var emptyValue: LocationLookupClient = Self(
        lookupCurrentLocation: {
            .applePark
        },
        search: { _ in
            .init(results: [])
        }
    )
}
