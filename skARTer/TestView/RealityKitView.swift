//
//  RealityKitView.swift
//  skARTer
//
//  Created by Csaba Bolyos on 04/06/2023.
//

import SwiftUI

struct RealityKitView: UIViewControllerRepresentable {
    
    let url: URL
    var realityViewController = RealityViewController()
    
    func makeUIViewController(context: Context) -> RealityViewController {
        
        print("makeUIViewController - realityViewController")
        return realityViewController
    }
    
    func updateUIViewController(_ uiViewController: RealityViewController, context: Context) {}
    
    func loadModel() {
        print("loadModel")
        GLBManager.shared.downloadAndStoreGLB(from: url) { savedURL in
            if let savedURL = savedURL {
                DispatchQueue.main.async {
                    self.realityViewController.loadModel(from: savedURL)
                }
            }
        }
    }
}
