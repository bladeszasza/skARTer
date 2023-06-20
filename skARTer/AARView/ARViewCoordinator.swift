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
        if let skateboard = parent.skateboardEntity,
           let wheelEntity1 = skateboard.findEntity(named: "wheel_01_low") as? ModelEntity,
           let wheelEntity2 = skateboard.findEntity(named: "wheel_02_low") as? ModelEntity,
           let wheelEntity3 = skateboard.findEntity(named: "wheel_03_low") as? ModelEntity,
           let wheelEntity4 = skateboard.findEntity(named: "wheel_04_low") as? ModelEntity {
            
            // Add all wheel entities into an array
            let wheels = [wheelEntity1, wheelEntity2, wheelEntity3, wheelEntity4]
            
            // Spin the wheels if the skateboard is moving
            spin(wheels: wheels)
        }
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if let meshAnchor = anchor as? ARMeshAnchor {
//            // The transformation matrix for a mesh anchor includes translation
//            let transform = meshAnchor.transform
//            let anchorPosition = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
//
//            // You could keep track of the lowest y value here
//            if anchorPosition.y < lowestY {
//                lowestY = anchorPosition.y
//                // Update the position of your horizontal plane here
//            }
//        }
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    func spin(wheels: [ModelEntity]){
        let rotationSpeed: Float = 0.1 // Adjust this value to change the speed of rotation
        
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
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard sender.state == .changed || sender.state == .ended else { return }
        
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            let scaleChange = Float(sender.scale)
            // Apply the scale change to the current scale
            let newScale = skateboardWithPhysics.scale * scaleChange
            skateboardWithPhysics.scale = newScale
            // Reset the sender scale so the next change starts from 1
            sender.scale = 1.0
        }
    }
    
    
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            // Adjust the force and direction values as necessary
            let force = SIMD3<Float>(800.0 * (parent.skateboardEntity?.scale.x ?? 1.0), 0.0, 0.0)
            skateboardWithPhysics.addForce(force, at:[0.11, 0.02, 0.0], relativeTo: skateboardWithPhysics)
            //            skateboardWithPhysics.applyImpulse(force, at:[0.0, 0.0, 0.0], relativeTo: skateboardWithPhysics)
        }
    }
    
    
    @objc func handleSwipeGestureLeft(_ sender: UISwipeGestureRecognizer) {
        let location = sender.location(in: parent.arView)
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            if location.y < parent.arView.bounds.size.height / 2 {
                // The swipe happened in the upper half of the screen
                // Adjust the force and direction values as necessary
                let force = SIMD3<Float>(0.0, 0.0, 6.0 * (parent.skateboardEntity?.scale.x ?? 1.0))
                skateboardWithPhysics.applyImpulse(force, at:[0.2155, 0.02, 0.0], relativeTo: skateboardWithPhysics)
                
            } else {
                // The swipe happened in the lower half of the screen
                // Adjust the force and direction values as necessary
                let force = SIMD3<Float>(0.0, 0.0, 6.0 * (parent.skateboardEntity?.scale.x ?? 1.0))
                skateboardWithPhysics.applyImpulse(force, at:[-0.2155, 0.02, 0.0], relativeTo: skateboardWithPhysics)
                
            }
            
        }
        
        
        
    }
    
    @objc func handleSwipeGestureRight(_ sender: UISwipeGestureRecognizer) {
        let location = sender.location(in: parent.arView)
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            if location.y < parent.arView.bounds.size.height / 2 {
                // The swipe happened in the upper half of the screen
                // Adjust the force and direction values as necessary
                let force = SIMD3<Float>(0.0, 0.0, 6.0 * (parent.skateboardEntity?.scale.x ?? -1.0))
                skateboardWithPhysics.applyImpulse(force, at:[0.2155, 0.02, 0.0], relativeTo: skateboardWithPhysics)
                
            } else {
                // The swipe happened in the lower half of the screen
                // Adjust the force and direction values as necessary
                let force = SIMD3<Float>(0.0, 0.0, 6.0 * (parent.skateboardEntity?.scale.x ?? -1.0))
                skateboardWithPhysics.applyImpulse(force, at:[-0.2155, 0.02, 0.0], relativeTo: skateboardWithPhysics)
                
            }
        }
        
        
    }
    
    
    
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard sender.state == .changed || sender.state == .ended else { return }
        
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            let rotationChange = Float(sender.rotation)
            // Create a rotation quaternion from the rotation change
            let rotationChangeQuaternion = simd_quatf(angle: rotationChange, axis: SIMD3<Float>(0, -1, 0))
            // Multiply the current rotation with the rotation change
            let newRotation = skateboardWithPhysics.transform.rotation * rotationChangeQuaternion
            skateboardWithPhysics.transform.rotation = newRotation
            // Reset the sender rotation so the next change starts from 0
            sender.rotation = 0.0
        }
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        // Handle double tap
        print("Double tapped!")
        // Your double tap logic here
        
//        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics, let initTransform = initialSkateboardTransform {
//
//            print("initial transform ation applied")
//            skateboardWithPhysics.transform = initTransform
//        }
    }
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform hit test
        let location = sender.location(in: parent.arView)
        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            
            let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
            
            // Define all your skateboards here
            let skateboards = [parent.skateboardEntity, parent.firstEntity, parent.secondEntity, parent.thirdEntity, parent.fourthEntity, parent.fifthEntity, parent.sixthEntity, parent.seventhEntity]
            
            // Find the closest skateboard
            var closestSkateboard = parent.skateboardEntity as? HasPhysics
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
                    // Add this line after you set up your skateboard
                    initialSkateboardTransform = closestSkateboard.transform
                    print("init set")
                }
                
                let tailOffset = SIMD3<Float>(0.0, 0.0, -0.1) // Adjust this value as necessary
                let adjustedPosition = position + tailOffset
                
                let distanceToSkateboard = length(adjustedPosition - closestSkateboard.position)
                
                // Normalize kickStrength by distance
                let normalizedKickStrength = kickStrength / max(distanceToSkateboard, 1)  * (parent.skateboardEntity?.scale.x ?? 1.0) // Avoid division by zero
                print("position: \(adjustedPosition)")
                print("kickStrength: \(kickStrength)")
                print("kickDirection: \(kickDirection)")
                print("normalizedKickStrength: \(normalizedKickStrength)")
                print("kickDirection * normalizedKickStrength: \(kickDirection * normalizedKickStrength)")
                
                
                
                closestSkateboard.applyImpulse(kickDirection * normalizedKickStrength, at: adjustedPosition, relativeTo: nil)
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
            return Float.random(in: 0.18...0.28) * (parent.skateboardEntity?.scale.x ?? 1.0)
        } else {
            print("static")
            // If the skateboard is not in motion, return a random value between 1.8 and 2.2
            return Float.random(in: 1.8...2.2) * (parent.skateboardEntity?.scale.x ?? 1.0)
            
        }
    }
    
    var catchStrength: Float {
        // Check if the skateboard is in motion
        return Float.random(in: 840.0...720.0) * (parent.skateboardEntity?.scale.x ?? 1.0)
    }
    
    
    var initialSkateboardTransform: Transform?
    
    static func setupARView(arView: ARView, context: UIViewRepresentableContext<ARViewContainer>, skateboardEntity: Binding<Entity?>, userDirection: Binding<SIMD3<Float>>) {
        
        print("setupARView")
        
        //                        arView.debugOptions = .showPhysics
//                arView.debugOptions.insert(.showSceneUnderstanding)
        
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
                context.coordinator.parent.eighthEntity = skateboard
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
                skateboardEntity.wrappedValue = skateboard
            }
            
            arView.scene.anchors.append(skateAnchor)
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = context.coordinator
        arView.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = context.coordinator
//        longPressGesture.num
        arView.addGestureRecognizer(longPressGesture)
        
        // Add swipe gesture recognizer
        let swipeGestureDown = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(handleSwipe(_:)))
        swipeGestureDown.delegate = context.coordinator
        swipeGestureDown.direction = .down // Specify the direction
        arView.addGestureRecognizer(swipeGestureDown)
        
        // Add swipe gesture recognizer
        let swipeGestureLeft = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(handleSwipeGestureLeft(_:)))
        swipeGestureLeft.delegate = context.coordinator
        swipeGestureLeft.direction = .left // Specify the direction
        arView.addGestureRecognizer(swipeGestureLeft)
        
        // Add swipe gesture recognizer
        let swipeGestureRight = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(handleSwipeGestureRight(_:)))
        swipeGestureRight.delegate = context.coordinator
        swipeGestureRight.direction = .right // Specify the direction
        arView.addGestureRecognizer(swipeGestureRight)
        
        // Add rotation gesture recognizer
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(handleRotation(_:)))
        rotationGesture.delegate = context.coordinator
        arView.addGestureRecognizer(rotationGesture)
        
//        // Add double tap gesture recognizer
//        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(handleDoubleTap(_:)))
//        doubleTapGesture.numberOfTapsRequired = 2
//        arView.addGestureRecognizer(doubleTapGesture)
        
        //        // Add pinch gesture recognizer
        //        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(handlePinch(_:)))
        //        rotationGesture.delegate = context.coordinator
        //        arView.addGestureRecognizer(pinchGesture)
        
    }
    
    // ...rest of your methods, copied over from Coordinator
    
    //... all the methods in the Coordinator class
}

