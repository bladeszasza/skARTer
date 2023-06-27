//
//  ContentView.swift
//  skARTer
//
//  Created by Csaba Bolyos on 24/05/2023.
//

import SwiftUI
import RealityKit

enum Screen {
    case arView
}

struct ContentView: View {
    @ObservedObject var recordingState: RecordingState
    @State private var user: User = User(level: 2, name: "Csabesz")
    @State private var skateboardEntity: Entity? = nil
    @State private var currentScreen: Screen? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Shred the world! ")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    self.recordingState.start() // Start the recording when the button is clicked
                    self.currentScreen = .arView // Update the currentScreen
                }) {
                    Text("skARTer - Level 0")
                        .font(.title)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .background( // Embed your button inside a NavigationLink, which will be invisible
                    NavigationLink(tag: .arView, selection: $currentScreen, destination: {
                        ARViewContainer(skateboardEntity: $skateboardEntity, user: $user)
                    }, label: { EmptyView() })
                )
                
                Button(action: {
                    self.recordingState.stop() // Stop the recording when the button is clicked
                }) {
                    Text("Stop Recording")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        
        
    
    }
}


