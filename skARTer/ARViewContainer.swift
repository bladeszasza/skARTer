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
        
        // Load the "Skateboard" scene from the "Experience" Reality File
        do {
            print("do")
            let skateAnchor = try Experience.loadSkateboard()
            let name = "primitive_0"
            // Find the entity
            if let deckEntity = findEntityRecursively(named: name, in: skateAnchor) as? (ModelEntity) {
                //deck dimensions
                let deckSize: SIMD3<Float> = [0.8011, 0.0416, 0.1921]
                let deckShape = ShapeResource.generateBox(size: deckSize)
                //wheel dimensions
                let wheelRadius: Float = 0.0498 / 2 // the radius is half of the diameter
                let wheelShape = ShapeResource.generateSphere(radius: wheelRadius)

                let wheelShapes = [
                    ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: [ 0.3, 0,  0.4]),
                    ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: [-0.3, 0,  0.4]),
                    ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: [ 0.3, 0, -0.4]),
                    ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: [-0.3, 0, -0.4])
                ]

                let shapes: [ShapeResource] = [deckShape] + wheelShapes

                
                  deckEntity.collision = CollisionComponent(shapes: shapes)
                  deckEntity.physicsBody = PhysicsBodyComponent(shapes: shapes, mass: 4.5)
                  deckEntity.collision = CollisionComponent(shapes: shapes)
                  deckEntity.physicsBody?.massProperties.centerOfMass.position = [0, 0,-27]
            }
            // Add the skateboard anchor to the scene
            arView.scene.anchors.append(skateAnchor)
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }

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
        
        return arView
    }

    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARViewContainer()
    }
}


// helper method probably will be placed elsewhere

func findEntityRecursively(named name: String, in entity: Entity) -> Entity? {
    print("findEntityRecursively")
    if entity.name == name {
        return entity
    }
    
    for child in entity.children {
        if let found = findEntityRecursively(named: name, in: child) {
            print("found")
            return found
        }
    }
    
    return nil
}

