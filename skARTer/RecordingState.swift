//
//  RecordingState.swift
//  skARTer
//
//  Created by Csaba Bolyos on 31/05/2023.
//

import Combine

class RecordingState: ObservableObject {
    @Published var isRecording = false

    func start() {
        isRecording = true
    }

    func stop() {
        isRecording = false
    }
}
