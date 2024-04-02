//
//  ContentView.swift
//  Whats The Weather
//
//  Created by Michael Stanziano on 3/28/24.
//

import CoreLocationUI
import LocationLookupFeature
import SwiftUI
import WeatherLookupFeature

struct ContentView: View {
    @State var tempString: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField(
                    text: $tempString,
                    prompt: Text("City")) {
                        Text("Location")
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                // TODO: Can this work in the Preview?
                LocationButton(.currentLocation) {
                    // TODO: Respond to action.
                }
                .labelStyle(.iconOnly)
                .symbolVariant(.circle)
                .cornerRadius(20)
                .foregroundColor(.white)
                .font(.callout)
            }
            Button {
                // TODO: Respond to action.
            } label: {
                Text("What's the weather?")
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
