//
//  RootViewController.swift
//  skARTer
//
//  Created by Csaba Bolyos on 31/05/2023.
//

import UIKit
import SwiftUI
import Combine

class RootViewController: UIViewController {
    
    private var replayAssistant = ReplayAssistant()
    private var recordingState = RecordingState()
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentView = ContentView(recordingState: recordingState)
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
        
        // Observe changes in recording state
        cancellable = recordingState.$isRecording.sink { [weak self] isRecording in
            if isRecording {
                self?.replayAssistant.startRecording()
            } else {
                self?.replayAssistant.stopRecording { [weak self] previewViewController in
                    if let previewViewController = previewViewController {
                        previewViewController.modalPresentationStyle = .fullScreen
                        previewViewController.view.backgroundColor = .black // Set black background color
                     
                        
                        DispatchQueue.main.async {
                            self?.present(previewViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        cancellable?.cancel()  // Stop observing when the view controller is deallocated
    }
    
}
