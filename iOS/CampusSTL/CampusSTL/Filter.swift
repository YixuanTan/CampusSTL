//
//  Filter.swift
//  CampusSTL
//
//  Created by Terry on 4/21/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import Foundation

//this is a singleton
class Filter {
    private static var filter: Filter!
    var shouldHaveLowestCapacity = 0
    var availableRoomOnly = false
    var shouldHaveWindow = false
    var shouldHaveBlackboard = false
    var shouldHaveMultipleOutlets = false
    private init() {}
    
    static func getFilterInstance() -> Filter {
        if filter == nil {
            filter = Filter()
        }
        return filter
    }
    
    func checkQualificationOfRoom(room: Room) -> Bool {
        if checkCapacity(room.capacity) &&
            checkAvailableRoomOnly(room.availability) &&
            checkWindow(room.numberOfWindows >= 1) &&
            checkBlackboard(room.numberOfBlackboards >= 1) &&
            checkOutlets(room.numberOfOutlets >= 1){
            return true
        }
        return false
    }
    
    func clearAll() {
        shouldHaveLowestCapacity = 0
        availableRoomOnly = false
        shouldHaveWindow = false
        shouldHaveBlackboard = false
        shouldHaveMultipleOutlets = false
        
    }
    
    func shouldHaveLowestCapacity(lowestCapacity: Int) {
        self.shouldHaveLowestCapacity = lowestCapacity
    }
    
    func availableRoomOnly(availableRoomOnly: Bool) {
        self.availableRoomOnly = availableRoomOnly
    }
    
    func shouldHaveWindow(shouldHaveWindow: Bool) {
        self.shouldHaveWindow = shouldHaveWindow
    }
    
    func shouldHaveBlackboard(shouldHaveBlackboard: Bool) {
        self.shouldHaveBlackboard = shouldHaveBlackboard
    }
    
    func shouldHaveMultipleOutlets(shouldHaveMultipleOutlets: Bool) {
        self.shouldHaveMultipleOutlets = shouldHaveMultipleOutlets
    }
    
    //check room validity
    func checkCapacity(capacity: Int) -> Bool {
        if self.shouldHaveLowestCapacity <= capacity {
            return true
        } else {
            return false
        }
    }
    
    func checkAvailableRoomOnly(availability: Bool) -> Bool {
        if self.availableRoomOnly {
            if availability == true {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func checkWindow(hasWindow: Bool) -> Bool {
        if self.shouldHaveWindow {
            if hasWindow {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func checkBlackboard(hasBlackboard: Bool) -> Bool {
        if self.shouldHaveBlackboard {
            if hasBlackboard {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func checkOutlets(multipleOutlets: Bool) -> Bool {
        if self.shouldHaveMultipleOutlets {
            if multipleOutlets {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

    
}
