//
//  User.swift
//  skARTer
//
//  Created by Csaba Bolyos on 25/06/2023.
//


import Combine

class User: ObservableObject {
    @Published var level: Int
    @Published var name: String

    init(level: Int = 0, name: String = "") {
        self.level = level
        self.name = name
    }
    
    init(name: String = "") {
        self.name = name
        self.level = 0
    }
    
    init(level: Int = 0) {
        self.level = level
        self.name = "Csabi"
    }

    func increaseLevel() {
        level += 1
    }

    func moveToZero() {
        level = 0
    }
}
