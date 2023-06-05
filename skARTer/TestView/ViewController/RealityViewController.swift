//
//  RealityViewController.swift
//  skARTer
//
//  Created by Csaba Bolyos on 04/06/2023.
//
import UIKit
import ARKit
import RealityKit
import Combine

class RealityViewController: UIViewController {
    
    var arView: ARView = ARView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        // Run the session with the configuration
        arView.session.run(config)
        
        // Set the frame of your ARView to cover the entire screen
        arView.frame = view.bounds
        
        // Add your ARView to the view hierarchy
        view.addSubview(arView)
        
        // Make sure ARView's autoresizingMask is set so it resizes with its parent view
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    func loadModel(from url: URL) {
        
        print("Checking file at \(url.absoluteString)")
        
        if FileManager.default.fileExists(atPath: url.path) {
            print("File exists, loading model")
            DispatchQueue.main.async {
                do {
                    let entity = try Entity.load(contentsOf: URL(string: url.absoluteString)!)
                    if let anchorEntity = entity as? AnchorEntity {
                        DispatchQueue.main.async {
                            self.arView.scene.addAnchor(anchorEntity)
                            print("AnchorEntity anchored")
                        }
                    }else{
                        let anchor = AnchorEntity()
                        anchor.addChild(entity)
                        DispatchQueue.main.async {
                            self.arView.scene.addAnchor(anchor)
                            print("ModelEntity anchored")
                        }
                    }
                    print("Finished loading")
                } catch {
                    print("Unable to load model: \(error)")
                }
            }
        } else {
            print("File does not exist, GLB download have failed")
        }
        
    }
}
