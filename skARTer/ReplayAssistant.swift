//
//  ReplayAssistant.swift
//  skARTer
//
//  Created by Csaba Bolyos on 31/05/2023.
//

import ReplayKit

class ReplayAssistant: NSObject, RPPreviewViewControllerDelegate {
    private let recorder = RPScreenRecorder.shared()

    func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }

        recorder.startRecording { (error) in
            if let error = error {
                print("There was an error starting the recording: \(error)")
            } else {
                print("Recording started successfully.")
            }
        }
    }

    func stopRecording(completion: @escaping (UIViewController?) -> Void) {
        recorder.stopRecording { (previewViewController, error) in
            if let error = error {
                print("There was an error stopping the recording: \(error)")
            } else {
                print("Recording stopped successfully.")
                if let previewViewController = previewViewController {
                    previewViewController.previewControllerDelegate = self
                    completion(previewViewController)
                }
            }
        }
    }

    // RPPreviewViewControllerDelegate method
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        // Dismiss previewController when user presses 'done'
        previewController.dismiss(animated: true, completion: nil)
    }
}
