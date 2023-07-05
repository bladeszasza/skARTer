//
//  ARSwipeGestureDelegate.swift
//  skARTer
//
//  Created by Csaba Bolyos on 27/06/2023.
//

import RealityKit
import ARKit

extension ARUIGestureRecognizerDelegate {
    
    
    func applySwipe(){
        if let skateboardWithPhysics = parent.skateboardEntity as? HasPhysics {
            // Adjust the force and direction values as necessary
            let force = SIMD3<Float>(380.0, -10.0, 0.0)
            skateboardWithPhysics.addForce(force, at:[0.11, 0.02, 0.0], relativeTo: skateboardWithPhysics)
            //            skateboardWithPhysics.applyImpulse(force, at:[0.0, 0.0, 0.0], relativeTo: skateboardWithPhysics)
        }
    }
}
