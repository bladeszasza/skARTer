//
//  RealityContentView.swift
//  skARTer
//
//  Created by Csaba Bolyos on 04/06/2023.
//

import SwiftUI

//https://openseauserdata.com/files/bc48722ff28a222d13dbf634e62a5dbb.glb
//https://openseauserdata.com/files/93eb2c2d2b9ab2e1da05308007143cca.glb
// LAU https://openseauserdata.com/files/9e6f21838b05179595591459e84c95f0.glb

// pinata just deck https://gateway.pinata.cloud/ipfs/QmUhnu55pqf1PPXjApWLHYw9av4M7vuwTm9CZQVBmcdZAw

// alraedy ion the documents erro rtest https://openseauserdata.com/files/448c1fcf835a35d7911ddc87e8378dc3.glb


//https://openseauserdata.com/files/71048fd86d3abecf56a2ce6565d8f300.glb
//https://openseauserdata.com/files/d23d89ad13bf2b0c137c38129f449d8f.glb
//https://openseauserdata.com/files/0e450c5ebb752ccdd2b5fa0d97da12fd.glb
//https://openseauserdata.com/files/1e23b556e07fb653bb538f8ffc2ba42d.glb
//https://openseauserdata.com/files/b1e1e80a7a2006598b20e3f01097c359.glb
//https://openseauserdata.com/files/f886842eb950813ba2f7ba775de327fc.glb

//WHEELS
//https://openseauserdata.com/files/afb49aede036bcb4f37f5785b88b9732.glb

//sample
//https://github.com/KhronosGroup/glTF-Sample-Models/blob/master/2.0/2CylinderEngine/glTF-Binary/2CylinderEngine.glb
//https://github.com/KhronosGroup/glTF-Sample-Models/blob/master/1.0/Avocado/glTF-Embedded/Avocado.gltf
//https://developer.apple.com/ar/photogrammetry/AirForce.usdz

struct RealityContentView: View {
    var body: some View {
        if let url = URL(string: "https://developer.apple.com/ar/photogrammetry/PegasusTrail.usdz") {
            let realityKitView = RealityKitView(url: url)
            realityKitView
                .onAppear {
                    realityKitView.loadModel()
                }
                .edgesIgnoringSafeArea(.all)
        }
    }
}

