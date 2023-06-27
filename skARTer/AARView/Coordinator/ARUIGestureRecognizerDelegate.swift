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
        
        
        guard let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics else { return }
        
        switch sender.state {
        case .began:
            
            let worldPositionOnSkateboard = getWorldPositionOnSkateboard(sender:sender)
            skateboardWithPhysics.addForce(catchDirection * catchStrength, at: worldPositionOnSkateboard, relativeTo: skateboardWithPhysics)
        case .ended, .cancelled, .failed:
            print("long press ended")
            // Stop applying force
            // Assuming there's a way to stop applying force, you would call it here.
            // The specifics would depend on the physics engine you're using.
            // For example, you might set the force to zero, or deactivate a continuous force.
        default:
            break
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
    
    // helps to apply the force for a period of 2-3 seconds instead of a bigger velocity push, to prevent more random board action
    var forceDuration: TimeInterval = 2.0 // Duration to apply the force
    var forceTimer: Timer? // Timer to control the force application duration

    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        // Stop the previous force timer if it exists
        forceTimer?.invalidate()
        
        applySwipe()
        
        // Start a new repeating force timer with a specified time interval
           forceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
               // Apply force periodically until the force duration is reached
               self?.applySwipe()
               self?.forceTimer?.invalidate()
           }
    }
    
    
    @objc func handleSwipeGestureLeft(_ sender: UISwipeGestureRecognizer) {
        let location = sender.location(in: parent.arView)
        let worldPositionOnSkateboard = getWorldPositionOnSkateboard(sender: sender)
        let force = SIMD3<Float>(0.0, 0.0, 6.0)
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            if location.y < parent.arView.bounds.size.height / 2 {
                // The swipe happened in the upper half of the screen
                // Adjust the force and direction values as necessary
                skateboardWithPhysics.applyImpulse(force, at:worldPositionOnSkateboard, relativeTo: skateboardWithPhysics)
            } else {
                // The swipe happened in the lower half of the screen
                // Adjust the force and direction values as necessary
                skateboardWithPhysics.applyImpulse(force, at:worldPositionOnSkateboard, relativeTo: skateboardWithPhysics)
            }
            
        }
        
    }
    
    @objc func handleSwipeGestureRight(_ sender: UISwipeGestureRecognizer) {
        let location = sender.location(in: parent.arView)
        let worldPositionOnSkateboard = getWorldPositionOnSkateboard(sender: sender)
        let force = SIMD3<Float>(0.0, 0.0, -6.0)
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            if location.y < parent.arView.bounds.size.height / 2 {
                // The swipe happened in the upper half of the screen
                // Adjust the force and direction values as necessary
                skateboardWithPhysics.applyImpulse(force, at:worldPositionOnSkateboard, relativeTo: skateboardWithPhysics)
            } else {
                // The swipe happened in the lower half of the screen
                // Adjust the force and direction values as necessary
                skateboardWithPhysics.applyImpulse(force, at:worldPositionOnSkateboard, relativeTo: skateboardWithPhysics)
            }
        }
        
        
    }
    
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard sender.state == .changed || sender.state == .ended else { return }
        
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {            let rotationChange = Float(sender.rotation)
            // Create a rotation quaternion from the rotation change
            let rotationChangeQuaternion = simd_quatf(angle: rotationChange, axis: SIMD3<Float>(0, -1, 0))
            // Multiply the current rotation with the rotation change
            let newRotation = skateboardWithPhysics.transform.rotation * rotationChangeQuaternion
            skateboardWithPhysics.transform.rotation = newRotation
            // Reset the sender rotation so the next change starts from 0
            sender.rotation = 0.0
        }
    }
    
//        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
//            // Handle double tap
//            print("Double tapped!")
//
//            if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics{
//
//                print("initial transform ation applied")
//                skateboardWithPhysics.reset()
//            }
//        }
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Perform hit test
        
        let worldPositionOnSkateboard = getWorldPositionOnSkateboard(sender: sender)
        if let closestSkateboard = parent.skateboardEntity as? HasPhysics {
            //                print("holdin on to the board  \(closestSkateboard)")
            if(notChoosen){
                applyPhysicsAndCollision(to: closestSkateboard)
                notChoosen = false
                // Add this line after you set up your skateboard
                initialSkateboardTransform = closestSkateboard.transform
                print("init set")
            }
            
            //                let tailOffset = SIMD3<Float>(0.0, 0.0, -0.1) // Adjust this value as necessary
            //                let adjustedPosition = worldPositionOnSkateboard + tailOffset
            
            closestSkateboard.applyImpulse(kickDirection * kickStrength, at: worldPositionOnSkateboard, relativeTo: closestSkateboard)
        }
        
    }
    
    // MARK: Helper Methods
    
    
    let deckSize = SIMD3<Float>(0.8011, 0.0416, 0.1921)
    let inMotionChanger: SIMD3<Float> = SIMD3<Float>(0.2, 1.0, 0.0)
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
            return [0.2, -1.0, 0.0]
        } else {
            return [0.8, -1.0, 0.0]
        }
    }
    
    
    var catchDirection: SIMD3<Float> {
        // Check if the skateboard is in motion
        if isSkateboardInMotion {
            return [0.2, -1.0, 0.0]
        } else {
            return [0.0, -1.0, 0.0]
        }
    }
    
    var kickStrength: Float {
        // Check if the skateboard is in motion
        if isSkateboardInMotion {
            print("is in motion")
            // If the skateboard is in motion, return a random value between 0.6 and 0.8
            return Float.random(in: 0.48...0.58)// * (parent.skateboardEntity?.scale.x ?? 1.0)
        } else {
            print("static")
            // If the skateboard is not in motion, return a random value between 1.8 and 2.2
            return Float.random(in: 6.8...8.2)// * (parent.skateboardEntity?.scale.x ?? 1.0)
            
        }
    }
    
    var catchStrength: Float {
        // Check if the skateboard is in motion
        return Float.random(in: 420.0...440.0)// * (parent.skateboardEntity?.scale.x ?? 1.0)
    }
    
    func getWorldPositionOnSkateboard(sender: UIGestureRecognizer)-> SIMD3<Float>{
        let location = sender.location(in: parent.arView)
        let relativeZ = (Float(location.x / parent.arView.bounds.width) - 0.5) * deckSize.z
        //due to the reason the height of the screen represents the height of the skateboard and the width the width
        let relativeX = (Float(location.y / parent.arView.bounds.height) - 0.5) * deckSize.x
        return SIMD3<Float>(relativeX, 0.02, relativeZ)
    }
    
    
}
