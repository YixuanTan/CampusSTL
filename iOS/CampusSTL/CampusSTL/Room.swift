//
//  Room.swift
//  CampusSTL
//
//  Created by Terry on 4/21/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import Foundation

class Room {
    var roomNumber = ""
    var capacity = 0
    var availability = false
    var numberOfWindows = 0
    var numberOfBlackboards = 0
    var numberOfOutlets = 0
    init(roomNumber: String = "", capacity: Int = 0, availability: Bool = false, numberOfWindows: Int = 0, numberOfBlackboards: Int = 0, numberOfOutlets: Int = 0) {
        self.roomNumber = roomNumber
        self.capacity = capacity
        self.availability = availability
        self.numberOfWindows = numberOfWindows
        self.numberOfBlackboards = numberOfBlackboards
        self.numberOfOutlets = numberOfOutlets
    }
    
    func isStudyRoom() -> Bool {
        if roomNumber == "rrrr" ||
            roomNumber == "eeee" ||
            roomNumber == "dddd" ||
            roomNumber == "xxxx" ||
            roomNumber == "xxxxx" ||
            roomNumber == "food" ||
            roomNumber == "info" ||
            roomNumber == "entr" {
            return false
        } else {
            return true
        }
    }
}
