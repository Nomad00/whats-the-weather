//
//  WhatsTheWeatherView.swift
//  Whats The Weather
//
//  Created by Michael Stanziano on 3/28/24.
//

import ComposableArchitecture
import CoreLocationUI
import LocationLookupFeature
import SwiftUI
import WeatherLookupFeature

struct WhatsTheWeatherView: View {
    @State var store: StoreOf<WhatsTheWeatherFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    TextField(
                        text: $store.searchQuery,
                        prompt: Text("City")
                    ) {
                        Text("City")
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                    // TODO: Can this work in the Preview?
                    LocationButton(.currentLocation) {
                        store.send(.lookupCurrentLocationButtonTapped)
                    }
                    .labelStyle(.iconOnly)
                    .symbolVariant(.circle)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .font(.callout)
                }

                if !store.searchResults.isEmpty {
                    withAnimation {
                        List {
                            ForEach(store.searchResults) { address in
                                VStack(alignment: .leading) {
                                    Button {
                                        store.send(.searchResultTapped(address))
                                    } label: {
                                        Text(address.title)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Initial State") {
    WhatsTheWeatherView(
        store: Store(initialState: WhatsTheWeatherFeature.State()) {
            WhatsTheWeatherFeature()
        }
    )
}

#Preview("Searching") {
    WhatsTheWeatherView(
        store: Store(
            initialState: WhatsTheWeatherFeature.State(
                searchQuery: "Cuper"
            )
        ) {
            WhatsTheWeatherFeature()
        }
    )
}

#Preview("Search Results") {
    WhatsTheWeatherView(
        store: Store(
            initialState: WhatsTheWeatherFeature.State(
                searchQuery: "Cuper",
                searchResults: AddressSearch.cupertinoSearch.results
            )
        ) {
            WhatsTheWeatherFeature()
        }
    )
}

