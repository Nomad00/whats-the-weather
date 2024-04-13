//
//  WhatsTheWeather.swift
//  Whats The Weather
//
//  Created by Michael Stanziano on 4/6/24.
//

import ComposableArchitecture

@Reducer
struct WhatsTheWeatherFeature {
    @ObservableState
    struct State {
        var city: String = ""
    }
    
    enum Action {
        case whatsTheWeatherButtonTapped
        case lookupCurrentLocationButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .whatsTheWeatherButtonTapped:
                return .none
            case .lookupCurrentLocationButtonTapped:
                return .none
            }
        }
    }
}
