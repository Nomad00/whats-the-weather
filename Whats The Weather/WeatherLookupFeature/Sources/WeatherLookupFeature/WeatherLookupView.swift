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
                            value: store.weather.temperature,
                            unit: $store.temperatureDisplayUnit.wrappedValue
                        ),
                        format: temperatureFormatStyle
                    )
                    /// This is only needed due to the issue with the `.abbreviated` `FormatStyle`.
                    Text(
                        store.temperatureDisplayUnit == .fahrenheit ? "F" : "C"
                    )
                }
                Text(store.weather.description)
            }
        }
    }
}

#Preview("Fahrenheit (Default)") {
    WeatherLookupView(
        store: Store(
            initialState: WeatherLookupFeature.State(
                weather: .mock
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
                weather: .mock,
                temperatureDisplayUnit: .celsius
            )
        ) {
            WeatherLookupFeature()
        }
    )
}
