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
        public init(
            weather: Weather,
            temperatureDisplayUnit: UnitTemperature = .fahrenheit,
            _$observationRegistrar: ObservationStateRegistrar = ComposableArchitecture.ObservationStateRegistrar()
        ) {
            self.weather = weather
            self.temperatureDisplayUnit = temperatureDisplayUnit
            self._$observationRegistrar = _$observationRegistrar
        }
        
        let weather: Weather
        var temperatureDisplayUnit: UnitTemperature = .fahrenheit
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
