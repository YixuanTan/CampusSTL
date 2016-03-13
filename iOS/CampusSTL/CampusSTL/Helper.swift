//
//  Helper.swift
//  CampusSTL
//
//  Created by Terry on 3/4/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import Foundation

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
    dateFormatter.dateFormat = "yyyy:MM:dd:hh:mm" //format style. Browse online to get a format that fits your needs.
    return dateFormatter.stringFromDate(date)
}

func convertStringtoDate(stringDate: String) -> NSDate {
    print(stringDate)
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy:MM:dd:hh:mm" //format style. Browse online to get a format that fits your needs.
    return dateFormatter.dateFromString(stringDate)!
}