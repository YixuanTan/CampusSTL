//
//  Helper.swift
//  CampusSTL
//
//  Created by Terry on 3/4/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import Foundation
import UIKit

struct CONSTANTS {
    static let numberOfFloorsInBuilding = 4
    static let floorPlanFilePrefix = "floor"
    static let roomIdFileOfEachFloorPrefix = "room"
}

func readAllRoomsFromDatabase(serverURL: NSURL) -> NSArray? {
    let receivedData = NSData(contentsOfURL: serverURL)
    do {
        let response: NSArray = try NSJSONSerialization.JSONObjectWithData(receivedData!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        return response
    } catch {
        return nil
    }
}

func readOneRoomFromDatabase(serverURL: NSURL) -> NSDictionary? {
    let receivedData = NSData(contentsOfURL: serverURL)
    do {
        let response: NSDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        //print(response)
        return response
    } catch {
        return nil
    }
}

func convertDatetoString(date: NSDate) -> String {
    //format date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy:MM:dd:HH:mm" //format style. Browse online to get a format that fits your needs.
    return dateFormatter.stringFromDate(date)
}

func convertStringtoDate(stringDate: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy:MM:dd:HH:mm" //format style. Browse online to get a format that fits your needs.
    return dateFormatter.dateFromString(stringDate)!
}

func getLengthOfLongestRowOfMatrix(lines: [String]) -> CGFloat {
    var maxLength = 0
    for oneLine in lines {
        let numberOfRoomsInARow = oneLine.componentsSeparatedByString(" ").count
        if numberOfRoomsInARow > maxLength {
            maxLength = numberOfRoomsInARow
        }
    }
    return CGFloat(maxLength)
}