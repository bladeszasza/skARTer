//
//  GLBManager.swift
//  skARTer
//
//  Created by Csaba Bolyos on 04/06/2023.
//

import Foundation

class GLBManager {
    
    static let shared = GLBManager()
    
    func downloadAndStoreGLB(from url: URL, completion: @escaping (URL?) -> Void) {
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            
            guard let localURL = localURL else {
                completion(nil)
                return
            }
            
            do {
                let fileName = url.lastPathComponent
                let cleanedFileName = fileName.replacingOccurrences(of: " ", with: "_")
                let applicationSupportDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let savedURL = applicationSupportDirectory.appendingPathComponent(cleanedFileName)
            
                try FileManager.default.moveItem(at: localURL, to: savedURL)
                completion(savedURL)
            } catch {
                print("File error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
