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
    let inMotionChanger: SIMD3<Float> = SIMD3<Float>(0.0, 1.0, -1.0)
    var notChoosen = true
    
    
    
    init(_ parent: ARViewContainer) {
        self.parent = parent
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let skateboard = parent.eighthEntity,
           let wheelEntity1 = skateboard.findEntity(named: "wheel_01_low") as? ModelEntity,
           let wheelEntity2 = skateboard.findEntity(named: "wheel_02_low") as? ModelEntity,
           let wheelEntity3 = skateboard.findEntity(named: "wheel_03_low") as? ModelEntity,
           let wheelEntity4 = skateboard.findEntity(named: "wheel_04_low") as? ModelEntity {
            
            // Add all wheel entities into an array
            let wheels = [wheelEntity1, wheelEntity2, wheelEntity3, wheelEntity4]
            
            // Check the physics body's linear velocity
            if let skateboardWithPhysics = skateboard as? HasPhysics {
                
//                skateboardWithPhysics.physicsMotion?.linearVelocity += (parent.forwardDirectionForSkateboard * parent.pushStrength)
            }
            // Spin the wheels if the skateboard is moving
            spin(wheels: wheels)
        }
    }
    
    
    func spin(wheels: [ModelEntity]){
        
        let rotationSpeed: Float = 0.01 // Adjust this value to change the speed of rotation
        
        for wheel in wheels {
            let deltaRotation = simd_quatf(angle: rotationSpeed, axis: SIMD3<Float>(0, 0, 1))
            // Change the rotation
            wheel.transform.rotation = wheel.transform.rotation * deltaRotation
        }
        
        
        
    }
    
    
    func lookAt(eye: simd_float3, center: simd_float3, up: simd_float3) -> simd_quatf {
        let z = normalize(eye - center)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let t = simd_float3(-dot(x, eye), -dot(y, eye), -dot(z, eye))
        
        return simd_quatf(simd_float4x4(
            simd_float4(x.x, y.x, z.x, 0),
            simd_float4(x.y, y.y, z.y, 0),
            simd_float4(x.z, y.z, z.z, 0),
            simd_float4(t.x, t.y, t.z, 1)
        ))
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
                
                //                    skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = position
                skateboardWithPhysics.addForce(kickDirection * catchStrength, at: position, relativeTo: nil)
                
            }
        }
    }
    
    
    //    @objc func handleTap(_ sender: UITapGestureRecognizer) {
    //        print("handleTap")
    //
    //
    //        if let skateboardWithPhysics = (parent.skateboardEntity as? HasPhysics) {
    //            if(notChoosen){
    //                print("applyed")
    //                applyPhysicsAndCollision(to: skateboardWithPhysics)
    //                notChoosen = false
    //            }
    //        }
    //
    //        // Perform hit test
    //        let location = sender.location(in: parent.arView)
    //        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
    //        print("results \(results)")
    //
    //        if let firstResult = results.first {
    //            print("had result \(firstResult)")
    //            // Apply impulse on the tapped location
    //            if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
    //
    //                    print("holdin on to the board  \(skateboardWithPhysics)")
    //                if (!isSkateboardInMotion){
    //                    //                    parent.startImpulse()
    //                }
    //                let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
    //                let tailOffset = SIMD3<Float>(0.0, 0.0, -0.1) // Adjust this value as necessary
    //                let adjustedPosition = position + tailOffset
    //                print("position: \(adjustedPosition)")
    //                print("strength: \(kickDirection * kickStrength)")
    //
    //                //                        skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = position
    //                skateboardWithPhysics.applyImpulse(kickDirection * kickStrength, at: adjustedPosition, relativeTo: nil)
    //            }
    //        }
    //
    //    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform hit test
        let location = sender.location(in: parent.arView)
        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            
            let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
            
            // Define all your skateboards here
            let skateboards = [parent.skateboardEntity, parent.firstEntity, parent.secondEntity, parent.thirdEntity, parent.fourthEntity, parent.fifthEntity, parent.sixthEntity, parent.seventhEntity]
            
            // Find the closest skateboard
            var closestSkateboard = parent.eighthEntity as? HasPhysics
            //                var minDistance: Float = Float.infinity
            //                for skateboard in skateboards {
            //                    if let skateboardWithPhysics = skateboard as? HasPhysics {
            //                        let skateboardPosition = skateboardWithPhysics.transform.translation
            //                        let distance = simd_distance(position, skateboardPosition)
            //                        if distance < minDistance {
            //                            minDistance = distance
            //                            closestSkateboard = skateboardWithPhysics
            //                        }
            //                    }
            //                }
            
            
            
            
            if let closestSkateboard = closestSkateboard {
                //                print("holdin on to the board  \(closestSkateboard)")
                if(notChoosen){
                    applyPhysicsAndCollision(to: closestSkateboard)
                    notChoosen = false
                }
                if (!isSkateboardInMotion){
                    // parent.startImpulse()
                }
                
                let tailOffset = SIMD3<Float>(0.0, 0.0, -0.1) // Adjust this value as necessary
                let adjustedPosition = position + tailOffset
                //                print("position: \(adjustedPosition)")
                //                print("strength: \(kickDirection * kickStrength)")
                
                closestSkateboard.applyImpulse(kickDirection * kickStrength, at: adjustedPosition, relativeTo: nil)
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
    
    var kickDirection: SIMD3<Float> {
        // Check if the skateboard is in motion
        if isSkateboardInMotion {
            return parent.userDirection * inMotionChanger
        } else {
            return parent.userDirection
        }
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
    
    var catchStrength: Float {
        // Check if the skateboard is in motion
        return Float.random(in: 4.8...4.2)
    }
    
    
    
    static func setupARView(arView: ARView, context: UIViewRepresentableContext<ARViewContainer>, skateboardEntity: Binding<Entity?>, userDirection: Binding<SIMD3<Float>>) {
//                        arView.debugOptions = .showPhysics
        //        arView.debugOptions.insert(.showSceneUnderstanding)
        
        // Set up the ARView's session configuration for LiDAR scanning
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        // Enable horizontal and vertical plane detection
        config.planeDetection = [.horizontal, .vertical]
        
        // Enable automatic environment texturing
        config.environmentTexturing = .automatic
        
        arView.environment.sceneUnderstanding.options = []
        arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        arView.environment.sceneUnderstanding.options.insert(.collision)
        arView.environment.sceneUnderstanding.options.insert(.physics)
        
        arView.renderOptions = [.disableFaceMesh, .disableHDR, .disableMotionBlur, .disableCameraGrain, .disableDepthOfField]
        
        arView.session.delegate = context.coordinator
        // Run the session with the configuration
        arView.session.run(config)
        
        do {
            let skateAnchor = try Experience.loadSkateboard()
            if let skateboard = skateAnchor.skateboard {
                skateboardEntity.wrappedValue = skateboard
                context.coordinator.parent.updateDirection(arView: arView)
            }
            
            if let skateboard = skateAnchor.firstBoard {
                context.coordinator.parent.firstEntity = skateboard
            }
            
            if let skateboard = skateAnchor.secondBoard {
                context.coordinator.parent.secondEntity = skateboard
            }
            
            if let skateboard = skateAnchor.thirdBoard {
                context.coordinator.parent.thirdEntity = skateboard
            }
            
            if let skateboard = skateAnchor.fourthBoarder {
                context.coordinator.parent.fourthEntity = skateboard
            }
            
            if let skateboard = skateAnchor.fifthBoard {
                context.coordinator.parent.fifthEntity = skateboard
            }
            
            
            if let skateboard = skateAnchor.sixthBoard {
                context.coordinator.parent.sixthEntity = skateboard
            }
            
            
            if let skateboard = skateAnchor.seventhBoard {
                context.coordinator.parent.seventhEntity = skateboard
            }
            
            if let skateboard = skateAnchor.centerBoard {
                context.coordinator.parent.eighthEntity = skateboard
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

