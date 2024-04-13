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
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        /// Handles the tap on the `LocationButton`.
        case lookupCurrentLocationButtonTapped
        /// Handles the response from ``LocationLookupClient.search``.
        case searchResponse(Result<AddressSearch, Error>) // TODO: Create specific error.
        /// Handles the tap on a search result, triggers call to ``WeatherLookupClient.lookupWeatherFor``.
        case searchResultTapped(AddressSearch.Address)
        /// Handles the response from ``WeatherLookupClient.lookupWeatherFor``.
        case weatherResponse(Result<Weather, Error>) // TODO: Create specific error.
    }
    
    @Dependency(\.locationLookupClient) var location
    @Dependency(\.weatherLookupClient) var weather
    
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
                return .run { send in
                    await send(
                        .weatherResponse(
                            Result {
                                try await self.weather.lookupWeatherFor((address.latitude, address.longitude))
                            }
                        )
                    )
                }
            case let .weatherResponse(.success(weather)):
                return .none
            case .weatherResponse(.failure):
                // TODO: Handle weather failures.
                return .none
            }
        }
    }
}
