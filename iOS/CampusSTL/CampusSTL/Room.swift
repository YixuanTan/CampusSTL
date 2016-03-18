//
//  Room.swift
//  CampusSTL
//
//  Created by Terry on 3/15/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import Foundation
import UIKit

class Room {
    init() {}
    init(roomId: String, capacity: Int) {
        self.roomId = roomId
        self.capacity = capacity
    }
    var roomId: String?
    var capacity: Int?
    var checkingTime: NSDate?
    var stayTime: Int? // in minutes
    var roomViewsize: CGSize?
    var otherInfo: NSDictionary?
    
}
