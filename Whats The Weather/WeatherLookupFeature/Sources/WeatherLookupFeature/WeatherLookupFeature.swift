//
//  WeatherLookupFeature.swift
//
//
//  Created by Michael Stanziano on 4/1/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct WeatherLookupFeature {
    public init() {}

    @ObservableState
    public struct State {
        public init(latitudeLongitudePair: LatitudeLongitudePair, weather: Weather? = nil, temperatureDisplayUnit: UnitTemperature = .fahrenheit, _$observationRegistrar: ObservationStateRegistrar = ComposableArchitecture.ObservationStateRegistrar()) {
            self.latitudeLongitudePair = latitudeLongitudePair
            self.weather = weather
            self.temperatureDisplayUnit = temperatureDisplayUnit
            self._$observationRegistrar = _$observationRegistrar
        }
        
        /// The coordinates, ``LatitudeLongitudePair``, to look up the weather for.
        let latitudeLongitudePair: LatitudeLongitudePair
        /// The displayed ``Weather`` object.
        var weather: Weather?
        /// Drives if the UI displays in Fahrenheit or Celsius.
        var temperatureDisplayUnit: UnitTemperature = .fahrenheit
    }
    
    public enum Action: BindableAction {
        /// Action for any custom handling of bindings.
        case binding(BindingAction<State>)
        /// Action connected to the `.task` view modifier.
        case onTask
        /// Triggers a refresh of the weather data.
        case refresh
        /// Handles the response from ``WeatherLookupClient.lookupWeatherFor``.
        case weatherResponse(Result<Weather, Error>) // TODO: Create specific error.
    }

    @Dependency(\.weatherLookupClient) var weather

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .onTask:
                return .run { [latitudeLongitudePair = state.latitudeLongitudePair] send in
                    await send(
                        .weatherResponse(
                            Result {
                                try await self.weather.lookupWeatherFor(latitudeLongitudePair)
                            }
                        )
                    )
                }
            case .refresh:
                state.weather = nil // TODO: Would be better to cache the previous `weather`.
                return .run { [latitudeLongitudePair = state.latitudeLongitudePair] send in
                    await send(
                        .weatherResponse(
                            Result {
                                try await self.weather.lookupWeatherFor(latitudeLongitudePair)
                            }
                        )
                    )
                }
            case let .weatherResponse(.success(weather)):
                state.weather = weather
                return .none
            case .weatherResponse(.failure):
                // TODO: Handle weather failures.
                return .none
            }
        }
    }
}
