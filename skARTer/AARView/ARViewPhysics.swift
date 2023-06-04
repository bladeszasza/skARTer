//
//  ARViewPhysics.swift
//  skARTer
//
//  Created by Csaba Bolyos on 01/06/2023.
//

import RealityKit

//deszka : [hossza, magassaga, szelessege]
//board : [length, height, width]

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
    entity.physicsBody?.massProperties.centerOfMass.position = [0.00, 0.07, 0.0]
}

extension ARViewContainer {

    func startImpulse() {
        if let skateboardWithPhysics = skateboardEntity as? HasPhysics {
            skateboardWithPhysics.physicsBody?.massProperties.centerOfMass.position = [0.00, 0.07, 0.0]
            skateboardWithPhysics.physicsMotion?.linearVelocity += (forwardDirectionForSkateboard * pushStrength)
        }
    }
}


