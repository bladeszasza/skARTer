//
//  RealityViewController.swift
//  skARTer
//
//  Created by Csaba Bolyos on 04/06/2023.
//
import UIKit
import RealityKit
import Combine

class RealityViewController: UIViewController {
    
    var arView: ARView = ARView(frame: .zero)
    
    //    func loadModel(from url: URL) {
    //
    //        print("Checking file at \(url.path)")
    //
    //        if FileManager.default.fileExists(atPath: url.path) {
    //            print("File exists, loading model")
    //
    //            do {
    //                let entity = try Entity.load(contentsOf: url)
    //                if let anchorEntity = entity as? AnchorEntity {
    //                    DispatchQueue.main.async {
    //                        self.arView.scene.addAnchor(anchorEntity)
    //                    }
    //                }
    //                print("Finished loading")
    //            } catch {
    //                print("Unable to load model: \(error)")
    //            }
    //        } else {
    //            print("File does not exist, GLB download may have failed")
    //        }
    //    }
    
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
                        }
                    }
                    print("Finished loading")
                    //                    let _ = Entity.loadAsync(contentsOf: URL(string: url.absoluteString)!)
                    //                        .print("Entity loading") // add this to print all events
                    //                        .sink(receiveCompletion: { loadCompletion in
                    //                            switch loadCompletion {
                    //                            case .finished:
                    //                                print("Finished loading")
                    //                            case .failure(let error):
                    //                                print("Unable to load model: \(error)")
                    //                            }
                    //                        }, receiveValue: { entity in
                    //                            // here, entity might be an AnchorEntity with multiple children
                    //
                    //                            // You can check if entity is an AnchorEntity
                    //                            if let anchorEntity = entity as? AnchorEntity {
                    //                                // do something with anchorEntity
                    //                                self.arView.scene.addAnchor(anchorEntity)
                    //                            }
                    //                        })
                    
                    
                    
                } catch {
                    print("Unable to load model: \(error)")
                }
            }
        } else {
            print("File does not exist, GLB download have failed")
        }
        
    }
}
