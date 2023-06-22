//
//  ARViewCoordinator.swift
//  skARTer
//
//  Created by Csaba Bolyos on 01/06/2023.
//

import RealityKit
import ARKit
import SwiftUI

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var parent: ARViewContainer
    
    
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
        
        // set up gesture delegate
        let rotationDelegate = ARUIGestureRecognizerDelegate(context.coordinator.parent)
        
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
        let tapGesture = UITapGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = rotationDelegate
        arView.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleLongPress(_:)))
        longPressGesture.delegate = rotationDelegate
//        longPressGesture.num
        arView.addGestureRecognizer(longPressGesture)
        
        // Add swipe gesture recognizer
        let swipeGestureDown = UISwipeGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleSwipe(_:)))
        swipeGestureDown.delegate = rotationDelegate
        swipeGestureDown.direction = .down // Specify the direction
        arView.addGestureRecognizer(swipeGestureDown)
        
        // Add swipe gesture recognizer
        let swipeGestureLeft = UISwipeGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleSwipeGestureLeft(_:)))
        swipeGestureLeft.delegate = rotationDelegate
        swipeGestureLeft.direction = .left // Specify the direction
        arView.addGestureRecognizer(swipeGestureLeft)
        
        // Add swipe gesture recognizer
        let swipeGestureRight = UISwipeGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleSwipeGestureRight(_:)))
        swipeGestureRight.delegate = rotationDelegate
        swipeGestureRight.direction = .right // Specify the direction
        arView.addGestureRecognizer(swipeGestureRight)
        
        // Add rotation gesture recognizer
        let rotationGesture = UIRotationGestureRecognizer(target: rotationDelegate, action: #selector(rotationDelegate.handleRotation(_:)))
        rotationGesture.delegate = rotationDelegate
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

