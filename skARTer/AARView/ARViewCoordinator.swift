//
//  ARViewCoordinator.swift
//  skARTer
//
//  Created by Csaba Bolyos on 01/06/2023.
//

import RealityKit
import ARKit
import SwiftUI

class ARViewCoordinator: NSObject, UIGestureRecognizerDelegate,  ARSessionDelegate {
    var parent: ARViewContainer
    
    init(_ parent: ARViewContainer) {
        self.parent = parent
    }
    
    
    func sessionWasInterrupted(_ session: ARSession) {
          // The session got interrupted (probably due to navigating back), so stop the recording
        
      }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer){
        // Perform hit test
        let location = sender.location(in: parent.arView)
        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            // Apply impulse on the tapped location
            if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
                let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
                
//                    print("position: \(position)")
//                    print("strength: \(parent.userDirection * kickStrength)")
                
//                    skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = position
                skateboardWithPhysics.addForce(parent.userDirection * kickStrength, at: position, relativeTo: nil)
                

            }
        }
        

            
    }
    
    var isSkateboardInMotion: Bool {
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            if let linearVelocity = skateboardWithPhysics.physicsMotion?.linearVelocity {
                // Calculate the magnitude of the velocity vector
                let speed = sqrt(linearVelocity.x * linearVelocity.x + linearVelocity.y * linearVelocity.y + linearVelocity.z * linearVelocity.z)
                
                // Compare the speed to the threshold
                return speed > 0.1
            }
        }
        return false
    }

    
    
    var kickStrength: Float {
        // Check if the skateboard is in motion
        if isSkateboardInMotion {
            print("is in motion")
            // If the skateboard is in motion, return a random value between 0.6 and 0.8
            return Float.random(in: 0.18...0.28)
        } else {
            print("static")
            // If the skateboard is not in motion, return a random value between 1.8 and 2.2
            return Float.random(in: 1.8...2.2)
        }
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform hit test
        let location = sender.location(in: parent.arView)
        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        
        if let firstResult = results.first {
            // Apply impulse on the tapped location
            if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
                let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
                
                print("position: \(position)")
                print("strength: \(parent.userDirection * kickStrength)")

//                        skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = position
                skateboardWithPhysics.applyImpulse(parent.userDirection * kickStrength, at: position, relativeTo: nil)
            }
        }
        
    }
    
    static func setupARView(arView: ARView, context: UIViewRepresentableContext<ARViewContainer>, skateboardEntity: Binding<Entity?>, userDirection: Binding<SIMD3<Float>>) {
        // Your setup logic here, extracted from makeUIView
        // Refer to skateboardEntity.wrappedValue and userDirection.wrappedValue to get/set values
        //        arView.debugOptions = .showPhysics
        
        // Set up the ARView's session configuration for LiDAR scanning
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        // Enable horizontal and vertical plane detection
        config.planeDetection = [.horizontal, .vertical]
        
        // Enable automatic environment texturing
        config.environmentTexturing = .automatic
        arView.session.delegate = context.coordinator
        // Run the session with the configuration
        arView.session.run(config)
        
        do {
            let skateAnchor = try Experience.loadSkateboard()
            if let skateboard = skateAnchor.skateboard {
                skateboardEntity.wrappedValue = skateboard
                context.coordinator.parent.updateDirection(arView: arView)
                if let skateboardWithPhysics = skateboard as? HasPhysics {
                    applyPhysicsAndCollision(to: skateboardWithPhysics)
                }
                //                startImpulse()
            }
            arView.scene.anchors.append(skateAnchor)
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(handleLongPress(_:)))
        arView.addGestureRecognizer(longPressGesture)
        
    }
    
    // ...rest of your methods, copied over from Coordinator
    
    //... all the methods in the Coordinator class
}

