//
//  ARViewExtensions.swift
//  skARTer
//
//  Created by Csaba Bolyos on 01/06/2023.
//

import RealityKit

extension ARViewContainer {
    func updateDirection(arView: ARView) {
        if let transform = arView.session.currentFrame?.camera.transform {
            let direction = SIMD3<Float>(-transform.columns.3.x, -transform.columns.3.y, -transform.columns.3.z)
            userDirection = normalize(direction)
        }
    }
}

