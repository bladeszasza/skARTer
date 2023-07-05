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
    
    // set up gesture delegate
    var gestureDelegate: ARUIGestureRecognizerDelegate
    
    init(_ parent: ARViewContainer) {
        self.parent = parent
        self.gestureDelegate = ARUIGestureRecognizerDelegate(parent)
        self.wheels = []
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Spin the wheels if the skateboard is moving
        spin(wheels: wheels)
    }
    
    var lowestY: Float = 0.0
    var planeEntity: ModelEntity?
    
    func setupHorizontalPlaneIn(arView: ARView) {
    
        // Create a plane mesh with a size of 10 meters by 10 meters
        let planeMesh = MeshResource.generatePlane(width: 10.0, depth: 10.0)
        let planeMaterial = SimpleMaterial(color: UIColor.red, isMetallic: false)
        let planeModel = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        
        // Create an anchor entity to hold the plane model
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.generateCollisionShapes(recursive: true)
        // Position the anchor entity at 0, lowestY, 0
        anchorEntity.position = [0, lowestY, 0]
        
        // Add the plane model to the anchor entity
        anchorEntity.addChild(planeModel)
        
        // Add the anchor entity to the scene
        arView.scene.addAnchor(anchorEntity)
        
        // Store a reference to the plane entity for future updates
        planeEntity = planeModel
    }
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("didAdd")
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                // The transformation matrix for a mesh anchor includes translation
                let translation = meshAnchor.transform.columns.3
                // You could keep track of the lowest y value here
                print("translation.y < lowestY ==  \(translation.y) < \(lowestY)")
                if translation.y < lowestY {
                    lowestY = translation.y
                    // Update the position of your horizontal plane here
                    if let planeEntity = planeEntity {
                        var newPosition = planeEntity.position
                        newPosition.y = lowestY + 1
                        planeEntity.position = newPosition
                    }
                }
            }
        }
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
    
    static func setupARView(arView: ARView, context: UIViewRepresentableContext<ARViewContainer>, skateboardEntity: Binding<Entity?>, user: Binding<User>) {
        
        print("setupARView")
        
        //                        arView.debugOptions = .showPhysics
//                        arView.debugOptions.insert(.showSceneUnderstanding)
        
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
            switch user.wrappedValue.level {
            case 0 :
                let skateAnchor = try Experience.loadSkateboard()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    arView.scene.anchors.append(skateAnchor)
                }
            case 1 :
                let skateAnchor = try Experience.loadLevel1()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    
                    arView.scene.anchors.append(skateAnchor)
                }
            case 2 :
                let skateAnchor = try Experience.loadLevel2()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    
                    arView.scene.anchors.append(skateAnchor)
                }
            case 3 :
                let skateAnchor = try Experience.loadLevel12()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    
                    arView.scene.anchors.append(skateAnchor)
                }
            case 4 :
                let skateAnchor = try Experience.loadLevel19()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    
                    arView.scene.anchors.append(skateAnchor)
                }
            default :
                let skateAnchor = try Experience.loadSkateboard()
                if let skateboard = skateAnchor.centerBoard {
                    skateboardEntity.wrappedValue = skateboard
                    
                    arView.scene.anchors.append(skateAnchor)
                }
            }
            
        } catch {
            print("Failed to load the Skateboard scene from Experience Reality File: \(error)")
        }
        // set up wheels
        context.coordinator.setUpWheels()
        
        //set horizontal plane
//        context.coordinator.setupHorizontalPlaneIn(arView:arView)
        
        print("set up tap ")
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = context.coordinator.gestureDelegate
        arView.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleLongPress(_:)))
        longPressGesture.delegate = context.coordinator.gestureDelegate
        longPressGesture.numberOfTouchesRequired = 2
        arView.addGestureRecognizer(longPressGesture)
        
        // Add swipe gesture recognizer
        let swipeGestureDown = UISwipeGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleSwipe(_:)))
        swipeGestureDown.delegate = context.coordinator.gestureDelegate
        swipeGestureDown.direction = .down // Specify the direction
        arView.addGestureRecognizer(swipeGestureDown)
        
        // Add swipe gesture recognizer
        let swipeGestureLeft = UISwipeGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleSwipeGestureLeft(_:)))
        swipeGestureLeft.delegate = context.coordinator.gestureDelegate
        swipeGestureLeft.direction = .left // Specify the direction
        arView.addGestureRecognizer(swipeGestureLeft)
        
        // Add swipe gesture recognizer
        let swipeGestureRight = UISwipeGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleSwipeGestureRight(_:)))
        swipeGestureRight.delegate = context.coordinator.gestureDelegate
        swipeGestureRight.direction = .right // Specify the direction
        arView.addGestureRecognizer(swipeGestureRight)
        
        // Add rotation gesture recognizer
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator.gestureDelegate, action: #selector(context.coordinator.gestureDelegate.handleRotation(_:)))
        rotationGesture.delegate = context.coordinator.gestureDelegate
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
    
    var wheels:[ModelEntity]
    func setUpWheels(){
        DispatchQueue.main.async { [self] in
            if let skateboard = parent.skateboardEntity,
               let wheelEntity1 = skateboard.findEntity(named: "wheel_01_low") as? ModelEntity,
               let wheelEntity2 = skateboard.findEntity(named: "wheel_02_low") as? ModelEntity,
               let wheelEntity3 = skateboard.findEntity(named: "wheel_03_low") as? ModelEntity,
               let wheelEntity4 = skateboard.findEntity(named: "wheel_04_low") as? ModelEntity {
                
                // Add all wheel entities into an array
                wheels = [wheelEntity1, wheelEntity2, wheelEntity3, wheelEntity4]
                
            }
        }
    }
    
    //... all the methods in the Coordinator class
}

