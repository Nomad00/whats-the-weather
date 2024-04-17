//
//  WhatsTheWeatherFeature.swift
//  Whats The Weather
//
//  Created by Michael Stanziano on 4/6/24.
//

import ComposableArchitecture
import LocationLookupFeature
import WeatherLookupFeature

@Reducer
struct WhatsTheWeatherFeature {
    @ObservableState
    struct State {
        /// Search string submitted to ``WeatherLookupClient``.
        var searchQuery: String = ""
        /// Collection of ``AddressSearch.Address`` provided by the ``WeatherLookupClient``.
        var searchResults: [AddressSearch.Address] = []
        /// Feature state for the ``WeatherLookupView``.
        @Presents var weatherLookup: WeatherLookupFeature.State?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        /// Handles the tap on the `LocationButton`.
        case lookupCurrentLocationButtonTapped
        /// Handles the response from ``LocationLookupClient.search``.
        case searchResponse(Result<AddressSearch, Error>) // TODO: Create specific error.
        /// Handles the tap on a search result, triggers call to ``WeatherLookupClient.lookupWeatherFor``.
        case searchResultTapped(AddressSearch.Address)
        case weatherLookup(PresentationAction<WeatherLookupFeature.Action>)
    }

    @Dependency(\.locationLookupClient) var location

    /// `enum` cases used as cancellation IDs for async calls.
    private enum CancelID { case search, weather }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.searchQuery):
                /// Don't search with an empty string.
                guard !state.searchQuery.isEmpty else { return .none }
                
                return .run { [search = state.searchQuery] send in
                    await send(
                        .searchResponse(
                            Result {
                                try await self.location.search(search)
                            }
                        )
                    )
                }
                .cancellable(id: CancelID.search)
            case .binding:
                return .none
            case .lookupCurrentLocationButtonTapped:
                return .none
            case let .searchResponse(.success(searchResponse)):
                state.searchResults = searchResponse.results
                return .none
            case .searchResponse(.failure):
                // TODO: Handle search failures.
                return .none
            case let .searchResultTapped(address):
                state.weatherLookup = .init(
                    latitudeLongitudePair: .init(
                        latitude: address.latitude,
                        longitude: address.longitude
                    )
                )
                return .none
            case .weatherLookup:
                /// Don't need to worry about any actions here.
                return .none
            }
        }
        .ifLet(
            \.$weatherLookup,
             action: \.weatherLookup
        ) {
            WeatherLookupFeature()
        }
    }
}
