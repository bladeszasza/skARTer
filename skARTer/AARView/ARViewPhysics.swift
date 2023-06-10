//
//  ARViewPhysics.swift
//  skARTer
//
//  Created by Csaba Bolyos on 01/06/2023.
//

import RealityKit

//deszka : [hossza, magassaga, szelessege]
//board : [length, height, width]

//func applyPhysicsAndCollision(to entity: HasPhysics) {
//    let shapes: [ShapeResource] = [
//        .generateBox(size: [0.8011, 0.0416, 0.1921]).offsetBy(translation: [0.0, 0.1916/2, 0.0]), // Deck
//        .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, 0.06845]), // Front-Right Wheel
//        .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, 0.06845]), // Front-Left Wheel
//        .generateSphere(radius: 0.028).offsetBy(translation: [0.2055, 0.023, -0.06845]), // Back-Right Wheel
//        .generateSphere(radius: 0.028).offsetBy(translation: [-0.2055, 0.023, -0.06845]) // Back-Left Wheel
//    ]
//    entity.collision = CollisionComponent(shapes: shapes)
//    entity.physicsBody = PhysicsBodyComponent(shapes: shapes, mass: 4.5)
//    entity.physicsBody?.massProperties.centerOfMass.position = [0.00, 0.07, 0.0]
//}

func applyPhysicsAndCollision(to entity: HasPhysics) {
    let deckSize = SIMD3<Float>(0.8011, 0.0416, 0.1921)
    let deckTranslation = SIMD3<Float>(0.0, 0.1916/2, 0.0)
    let deckShape = ShapeResource.generateBox(size: deckSize).offsetBy(translation: deckTranslation)
    let deckMass: Float = 2.0
    let deckFriction: Float = 0.6
    let deckRestitution: Float = 0.2
//    let deckDamping: Float = 0.2
//    let deckDensity: Float = 550
    
    let wheelRadius: Float = 0.028
    let wheelFrontRightTranslation = SIMD3<Float>(0.2055, 0.023, 0.06845)
    let wheelFrontLeftTranslation = SIMD3<Float>(-0.2055, 0.023, 0.06845)
    let wheelBackRightTranslation = SIMD3<Float>(0.2055, 0.023, -0.06845)
    let wheelBackLeftTranslation = SIMD3<Float>(-0.2055, 0.023, -0.06845)
    let wheelShapes: [ShapeResource] = [
        ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: wheelFrontRightTranslation),
        ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: wheelFrontLeftTranslation),
        ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: wheelBackRightTranslation),
        ShapeResource.generateSphere(radius: wheelRadius).offsetBy(translation: wheelBackLeftTranslation)
    ]
    let wheelMass: Float = 0.12
//    let wheelFriction: Float = 1.0
//    let wheelRestitution: Float = 0.2
//    let wheelDamping: Float = 0.1
//    let wheelDensity: Float = 0.1
    
    let truckSize = SIMD3<Float>(0.035, 0.03, 0.088)
    let truckFrontTranslation = SIMD3<Float>(0.2055, 0.02, 0.0)
    let truckBackTranslation = SIMD3<Float>(-0.2055, 0.02, 0.0)
    let truckShapes: [ShapeResource] = [
        ShapeResource.generateBox(size: truckSize).offsetBy(translation: truckFrontTranslation),
        ShapeResource.generateBox(size: truckSize).offsetBy(translation: truckBackTranslation)
    ]
    let truckMass: Float = 0.355
    
    let shapes: [ShapeResource] = [deckShape] + wheelShapes + truckShapes
    
    entity.collision = CollisionComponent(shapes: shapes)
    entity.physicsBody = PhysicsBodyComponent(shapes: shapes, mass: deckMass + 4 * wheelMass + 2 * truckMass, material: PhysicsMaterialResource.generate(friction : deckFriction, restitution : deckRestitution))
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


