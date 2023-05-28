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
    
    
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.debugOptions = .showPhysics         // shape visualization
        
 
        
        // Set up the ARView's session configuration for LiDAR scanning
        let config = ARWorldTrackingConfiguration()
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            // Enable Scene Reconstruction to generate a 3D mesh of the environment
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
//                print("skateboard \(skateboard) and \(skateAnchor)")
                updateDirection(arView: arView)
                applyPhysicsAndCollision(to: skateboard)
            }
            arView.scene.anchors.append(skateAnchor)
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

var userDirection: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
var pushStrength: Float = 0.1 // adjust this to achieve the desired push strength
let tailCoordinates  = SIMD3<Float>(0.385,-0.0497,0.0)


func updateDirection(arView: ARView) {
    // Calculate the direction based on the camera's transform
    if let transform = arView.session.currentFrame?.camera.transform {
        let direction = SIMD3<Float>(-transform.columns.3.x, -transform.columns.3.y, -transform.columns.3.z)
        userDirection = normalize(direction)
    }
}


struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARViewContainer()
    }
}

func loadSkateboard(){

}
//deszka : [hossza, magassaga, szelessege]

func applyPhysicsAndCollision(to entity: Entity) {
    if  let skateboardWithPhisics = entity as? HasPhysics  {
        let shapes: [ShapeResource] = [
            .generateBox(size: [0.8011, 0.0416, 0.1921]).offsetBy(translation: [0.0, 0.1916/2, 0.0]), // Deck
            .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, 0.06845]), // Front-Right Wheel
            .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, 0.06845]), // Front-Left Wheel
            .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, -0.06845]), // Back-Right Wheel
            .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, -0.06845]) // Back-Left Wheel
        ]
        skateboardWithPhisics.collision = CollisionComponent(shapes: shapes)
        skateboardWithPhisics.physicsBody = PhysicsBodyComponent(shapes: shapes, mass: 4.5)
        skateboardWithPhisics.physicsBody?.massProperties.centerOfMass.position = [0.305, 0.0, 0.0]
        
        skateboardWithPhisics.applyImpulse( (userDirection * pushStrength), at: tailCoordinates, relativeTo: nil )

    }
}
