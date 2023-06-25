//
//  ContentView.swift
//  skARTer
//
//  Created by Csaba Bolyos on 24/05/2023.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var skateboardEntity: Entity? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to skARTer")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: ARViewContainer(skateboardEntity: $skateboardEntity)) {
                    Text("Start AR Scene")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}




#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif


