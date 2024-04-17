//
//  WeatherLookupView.swift
//
//
//  Created by Michael Stanziano on 4/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public struct WeatherLookupView: View {
    public init(store: StoreOf<WeatherLookupFeature>) {
        self.store = store
    }
    
    @State var store: StoreOf<WeatherLookupFeature>

    private let temperatureFormatStyle = Measurement<UnitTemperature>.FormatStyle(
        width: .narrow /// Should be able to use `.abbreviated` here, however it was not working 🤔
    )

    public var body: some View {
        /// `WithPerceptionTracking` is needed for pre-iOS 17 support.
        WithPerceptionTracking {
            if let weather = store.weather {
                VStack {
                    Button {
                        store.send(
                            .binding(
                                .set(
                                    \.temperatureDisplayUnit,
                                     store.temperatureDisplayUnit == .fahrenheit ? .celsius : .fahrenheit
                                )
                            )
                        )
                    } label: {
                        Text("Toggle unit format.")
                    }

                    HStack {
                        Text(
                            Measurement<UnitTemperature>.init(
                                value: weather.temperature,
                                unit: $store.temperatureDisplayUnit.wrappedValue
                            ),
                            format: temperatureFormatStyle
                        )
                        /// This is only needed due to the issue with the `.abbreviated` `FormatStyle`.
                        Text(
                            store.temperatureDisplayUnit == .fahrenheit ? "F" : "C"
                        )
                    }
                    Text(weather.description)
                    Button {
                        store.send(.refresh)
                    } label: {
                        Text("Refresh")
                    }
                }
            } else {
                ProgressView {
                    Text("Checking the weather...")
                }
            }
        }
        .task {
            await store.send(.onTask).finish()
        }
    }
}

#Preview("Fahrenheit (Default)") {
    WeatherLookupView(
        store: Store(
            initialState: WeatherLookupFeature.State(
                latitudeLongitudePair: .applePark
            )
        ) {
            WeatherLookupFeature()
        }
    )
}

#Preview("Celsius") {
    WeatherLookupView(
        store: Store(
            initialState: WeatherLookupFeature.State(
                latitudeLongitudePair: .applePark,
                temperatureDisplayUnit: .celsius
            )
        ) {
            WeatherLookupFeature()
        }
    )
}

#Preview("Loading | Refreshable") {
    WeatherLookupView(
        store: Store(
            initialState: WeatherLookupFeature.State(
                latitudeLongitudePair: .applePark
            )
        ) {
            WeatherLookupFeature()
                .dependency(\.weatherLookupClient, .loadingValue)
        }
    )
}
