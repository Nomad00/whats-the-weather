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

// TODO: Move to dedicated file?
/// Type returned by ``LocationLookupClient.search``, notably containing the ``results`` collection of ``Address``.
public struct AddressSearch {
    /// Collection of ``Address`` returned by ``LocationLookupClient.search``.
    public var results: [Address]

    /// Type representing an individual result returned by ``LocationLookupClient.search``.
    public struct Address: Identifiable {
        /// Unique identifier of the address.
        public let id: UUID
        /// The user friendly string representation of the search result.
        ///
        /// The granularity of this result will match the search input. A city will result in a city, while a street address will result in a street address.
        /// - note: Mapped from `title` property of `MKAnnotation`.
        public let title: String
        /// The `latitude` value for the result.
        public let latitude: Double
        /// The `longitude` value for the result.
        public let longitude: Double
    }
}

#if DEBUG
extension AddressSearch {
    /// Mock ``AddressSearch`` representing Cupertino, CA used for previews.
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
    /// `LocationLookupClient` facilitates searching for a city from an entered string.
    ///
    /// Included are four implementations:
    /// - `liveValue`: Leverages `MKLocalSearch` to create an ``AddressSearch`` from the given string.
    /// - `previewValue`: Always returns the ``AddressSearch.cupertinoSearch`` as a mock value.
    /// - `emptyValue`: Returns an empty ``AddressSearch``.
    /// - `testValue`: An unimplemented version which ensures definition within tests.
    public var locationLookupClient: LocationLookupClient {
        get { self[LocationLookupClient.self] }
        set { self[LocationLookupClient.self] = newValue }
    }
}

/// A type that facilitates searching for a city from an entered string.
public struct LocationLookupClient {
    // TODO: Implement if time.
//    public var lookupCurrentLocation: @Sendable () async throws -> CLLocation

    /// Performs a search with the provided `String`, creating an ``AddressSearch`` with the results.
    /// 
    /// Example:
    /// ```swift
    /// let addresses: AddressSearch = try await self.location.search("Cupertino")
    /// ```
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
//        lookupCurrentLocation: {
//            // TODO: Build the live client.
//            .applePark
//        },
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
    /// An unimplemented version which ensures definition within tests.
    public static var testValue: LocationLookupClient = Self(
//        lookupCurrentLocation: unimplemented("LocationLookupClient.lookupCurrentLocation"),
        search: unimplemented("LocationLookupClient.search")
    )
    
    /// Always returns the ``AddressSearch.cupertinoSearch`` as a mock value.
    public static var previewValue: LocationLookupClient = Self(
//        lookupCurrentLocation: {
//            .applePark
//        },
        search: { _ in
            .cupertinoSearch
        }
    )

    /// Returns an empty ``AddressSearch``.
    public static var emptyValue: LocationLookupClient = Self(
//        lookupCurrentLocation: {
//            .applePark
//        },
        search: { _ in
            .init(results: [])
        }
    )
}
