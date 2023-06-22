//
//  ARUIGestureRecognizerDelegate.swift
//  skARTer
//
//  Created by Csaba Bolyos on 22/06/2023.
//


import RealityKit
import ARKit
import SwiftUI



class ARUIGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    var parent: ARViewContainer
    
    init(_ parent: ARViewContainer) {
        print("parent set up")
        self.parent = parent
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer){
        print("long press")
        // Perform hit test
        let location = sender.location(in: parent.arView)
        let results = parent.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            // Apply impulse on the tapped location
            if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
                let position = SIMD3<Float>(firstResult.worldTransform.columns.3.x, firstResult.worldTransform.columns.3.y, firstResult.worldTransform.columns.3.z)
                print("press applied")
                //                    skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = position
                skateboardWithPhysics.addForce(kickDirection * catchStrength, at: position, relativeTo: skateboardWithPhysics)
            }
        }
    }
    
//    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        guard sender.state == .changed || sender.state == .ended else { return }
//
//        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
//            let scaleChange = Float(sender.scale)
//            // Apply the scale change to the current scale
//            let newScale = skateboardWithPhysics.scale * scaleChange
//            skateboardWithPhysics.scale = newScale
//            // Reset the sender scale so the next change starts from 1
//            sender.scale = 1.0
//        }
//    }
    
    
    
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
        print("rotation")
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
    
//    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
//        // Handle double tap
//        print("Double tapped!")
//         Your double tap logic here
//
//        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics, let initTransform = initialSkateboardTransform {
//
//            print("initial transform ation applied")
//            skateboardWithPhysics.transform = initTransform
//        }
//    }
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("tap press")
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
    
    // MARK: Helper Methods

    
    let inMotionChanger: SIMD3<Float> = SIMD3<Float>(0.0, 1.0, -1.0)
    var notChoosen = true
    var initialSkateboardTransform: Transform?
    
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
        return Float.random(in: 420.0...440.0) * (parent.skateboardEntity?.scale.x ?? 1.0)
    }
    
    
}
