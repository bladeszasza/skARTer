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
     @State private var userDirection: SIMD3<Float> = SIMD3<Float>(0, 0, 0) // Direction of the user
    
    let impulseDuration: TimeInterval = 1 // in seconds

    
    func makeUIView(context: Context) -> ARView {
        arView.debugOptions = .showPhysics
        
        // Set up the ARView's session configuration for LiDAR scanning
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        // Enable horizontal and vertical plane detection
        config.planeDetection = [.horizontal, .vertical]
        
        // Enable automatic environment texturing
        config.environmentTexturing = .automatic
        
        // Run the session with the configuration
        arView.session.run(config)
        
        do {
            let skateAnchor = try Experience.loadSkateboard()
            if let skateboard = skateAnchor.skateboard {
                skateboardEntity = skateboard
                updateDirection(arView: arView)
                if let skateboardWithPhysics = skateboard as? HasPhysics {
                    applyPhysicsAndCollision(to: skateboardWithPhysics)
                }
                startImpulse()
            }
            arView.scene.anchors.append(skateAnchor)
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateDirection(arView: ARView) {
        if let transform = arView.session.currentFrame?.camera.transform {
            let direction = SIMD3<Float>(-transform.columns.3.x, -transform.columns.3.y, -transform.columns.3.z)
            userDirection = normalize(direction)
        }
    }

    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            // Perform hit test
            let location = sender.location(in: parent.arView)
            let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            
            if let firstResult = results.first {
                // Apply impulse on the tapped location
                if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
                    let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
                    skateboardWithPhysics.applyImpulse(parent.userDirection * pushStrength, at: position, relativeTo: nil)
                }
            }
        }
    }
}

var pushStrength: Float = 0.1 // adjust this to achieve the desired push strength
let tailCoordinates  = SIMD3<Float>(0.385,-0.0497,0.0)


//deszka : [hossza, magassaga, szelessege]

func applyPhysicsAndCollision(to entity: HasPhysics) {
    let shapes: [ShapeResource] = [
        .generateBox(size: [0.8011, 0.0416, 0.1921]).offsetBy(translation: [0.0, 0.1916/2, 0.0]), // Deck
        .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, 0.06845]), // Front-Right Wheel
        .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, 0.06845]), // Front-Left Wheel
        .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, -0.06845]), // Back-Right Wheel
        .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, -0.06845]) // Back-Left Wheel
    ]
    entity.collision = CollisionComponent(shapes: shapes)
    entity.physicsBody = PhysicsBodyComponent(shapes: shapes, mass: 4.5)
    entity.physicsBody?.massProperties.centerOfMass.position = [0.305, 0.0, 0.0]
}

extension ARViewContainer {
func startImpulse() {
        impulseStartDate = Date()
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard let impulseStartDate = impulseStartDate else { return }
            if Date().timeIntervalSince(impulseStartDate) >= impulseDuration {
                timer.invalidate()
            } else {
                if let skateboardWithPhysics = skateboardEntity as? HasPhysics {
                    skateboardWithPhysics.applyImpulse(userDirection * pushStrength, at: tailCoordinates, relativeTo: nil)
                }
            }
        }
    }
}

//struct ARViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        ARViewContainer( skateboardEntity: nil)
//    }
//}
