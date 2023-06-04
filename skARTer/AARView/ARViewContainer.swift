//
//  ARViewContainer.swift
//  skARTer
//
//  Created by Csaba Bolyos on 24/05/2023.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {

    // Make these as properties
    var arView: ARView = ARView(frame: .zero)
    
    @Binding var skateboardEntity: Entity? // Used to store the skateboard entity
    @State private var impulseStartDate: Date? = nil // Used to store the start date of impulse
    @State var userDirection: SIMD3<Float> = SIMD3<Float>(0.0, -1.1, 0.7) // Direction of the user
    
    let forwardDirectionForSkateboard: SIMD3<Float> = SIMD3<Float>(1.0, 0.0, 0.0)
    var pushStrength: Float = 5.8 // adjust this to achieve the desired push strength
    let impulseDuration: TimeInterval = 1 // in seconds

    func dismantleUIView(_ uiView: ARView, context: Context) {
        print("VIEW CLEAN UP")
    }
    
//    func punchTheClown() {
//        arView.session.pause()
//        arView.removeFromSuperview()
//    }

    func makeUIView(context: Context) -> ARView {
        ARViewCoordinator.setupARView(arView: arView, context: context, skateboardEntity: $skateboardEntity, userDirection: $userDirection)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> ARViewCoordinator {
        return ARViewCoordinator(self)
    }
}

