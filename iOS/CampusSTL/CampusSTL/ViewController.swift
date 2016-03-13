//
//  ViewController.swift
//  CampusSTL
//
//  Created by Terry on 3/2/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//
/*
    userDefault = [ "timeRemaining":"0",
                    "RIN":"meiyourin",
                    "checkedInRoomId":"0",
                    "numberOfRoomCheckedIn:"0"]
*/

import UIKit
import SpriteKit

let serverURL = "52.90.85.173:3000"
//let serverURL = "192.168.0.103:3000"
var timer = -1

class ViewController: UIViewController {
    
    let userDefault = NSUserDefaults.standardUserDefaults()
    var numberOfRoomCheckedIn = 0
    var checkedInRoomId = "0"
    var clock = NSTimer()
    var floorButtons: [UIButton]!
    var allRoomData = NSMutableDictionary()//Dictionary<String, Dictionary<String, String> >()//roomNumber:[field: value]
    var floorShowing = 1
    
    @IBOutlet weak var RINLabel: UILabel!
    @IBAction func linkTapped(sender: UIButton) {
        openLink(sender.titleLabel!.text!)
    }
    
    @IBOutlet weak var floorView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var floorOneButton: UIButton!
    @IBOutlet weak var floorTwoButton: UIButton!
    @IBOutlet weak var floorThreeButton: UIButton!
    @IBOutlet weak var floorFourButton: UIButton!
    
    @IBAction func floorButtonTapped(sender: UIButton) {
        switch sender.titleLabel!.text! {
            case "Floor 1":
                floorShowing = 1
                refresh()
            case "Floor 2":
                floorShowing = 2
                refresh()
            case "Floor 3":
                floorShowing = 3
                refresh()
            case "Floor 4":
                floorShowing = 4
                refresh()
            default: break
        }
        for oneFloorButton in floorButtons! {
            oneFloorButton.backgroundColor = UIColor.whiteColor()
            oneFloorButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
        sender.backgroundColor = UIColor.grayColor()
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    @IBAction func refresh() {
        //spinner?.startAnimating()
        removeAllRoomsFromCurrentFloor()
        readAllFromDatabase()
        while allRoomData.allKeys.count==0 {}
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target: self, selector: "stopSpinner", userInfo: nil, repeats: false)
        loadFloor(floorShowing)
        updateRINLabel()
    }
    
    func updateRINLabel() {
        let RIN = userDefault.stringForKey("RIN")
        if RIN != nil {
            if (RIN!) != "meiyourin" {
                RINLabel.text = "You have checked in with RIN: \(RIN!)"
            } else {
                RINLabel.text = ""
            }
        } else {
            RINLabel.text = ""
        }
    }
    
    func stopSpinner() {
        spinner?.stopAnimating()
    }
    
    func resetNumberOfRoomCheckedIn() {
        print(userDefault.stringForKey("checkedInRoomId"))
        if userDefault.stringForKey("checkedInRoomId") != nil {
            checkedInRoomId = userDefault.stringForKey("checkedInRoomId")!
            if let checkedInRoom = allRoomData[checkedInRoomId] as? NSDictionary {
                if let didCheckIn = checkedInRoom["occupied"] as? String {
                    if didCheckIn == "0" {
                        userDefault.setObject("0", forKey: "numberOfRoomCheckedIn")
                    }
                }
            } else if checkedInRoomId == "0" {
                userDefault.setObject("0", forKey: "numberOfRoomCheckedIn")
            }
        } else if userDefault.stringForKey("checkedInRoomId")==nil {
            userDefault.setObject("0", forKey: "numberOfRoomCheckedIn")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.accessibilityIdentifier = "FloorView"
        //Do any additional setup after loading the view, typically from a nib.
        floorView.backgroundColor =  UIColor.grayColor()//UIColor(patternImage: UIImage(named: "chair.png")!)
        readAllFromDatabase()//should update data every 1min or so
        floorButtons = [floorOneButton, floorTwoButton, floorThreeButton, floorFourButton]
        //print("viewcontroller ------------------ \(userDefault)")
        if let numberOfRoomCheckedInStr = userDefault.stringForKey("numberOfRoomCheckedIn") {
            numberOfRoomCheckedIn = Int(numberOfRoomCheckedInStr)!
        }
        if let roomNumber = userDefault.stringForKey("checkedInRoomId") {
            checkedInRoomId = roomNumber
        }
        if let timeRemaining = userDefault.stringForKey("timeRemaining") {
            timer = Int(timeRemaining)!
        }
        clock = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "countDown", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        floorButtonTapped(floorButtons[floorShowing-1])
    }
    
    func countDown() {
        timer--
        let roomNumber = userDefault.stringForKey("checkedInRoomId")
        if timer == 1 {// should change back to 2
            let ac = UIAlertController(title: "2 minutes left", message: "Please check out or add time", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Check out", style: .Default, handler: {(action)->Void  in
                self.performSegueWithIdentifier("checkin", sender: roomNumber)
            }))
            ac.addAction(UIAlertAction(title: "Add time", style: .Default, handler: {(action)->Void  in
                self.performSegueWithIdentifier("addTime", sender: roomNumber)
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(ac, animated: true, completion: nil)
        } else if timer == 0 {
            automaticallyCheckout()
        }
    }
    
    func automaticallyCheckout() {
        //yet to implement
        let roomNumber = userDefault.stringForKey("checkedInRoomId")!
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        print(url)
        let parameters = ["roomNumber":roomNumber,"occupied": "0","checkinTime":"-1","stayTime": "0","userId":"0"] as Dictionary<String, String>
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)//sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error as NSError{
            print("Fail to create json \(error.localizedDescription)")
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            //if error, return false
        }
        task.resume()
        checkedInRoomId = "0"
        userDefault.setObject("0", forKey: "numberOfRoomCheckedIn")
        userDefault.setObject("0", forKey: "checkedInRoomId")
        userDefault.setObject("meiyourin", forKey: "RIN")
        timer = -1

        let ac = UIAlertController(title: "Time is up", message: "You have been checked out", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
            self.refresh()
        }))//yet to be implemented
        presentViewController(ac, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInView(floorView)
        for oneRoom in floorView.subviews {
            let oneRoomFrame = oneRoom.frame//view.convertRect(oneRoom.frame, fromView: )
            //print(floorView.subviews.count)
            //print(oneRoom.frame.origin)
            if CGRectContainsPoint(oneRoomFrame, touchLocation) {
                let roomNumber = oneRoom.accessibilityIdentifier
                if roomNumber != nil {
                    switch roomNumber! {
                        case "-1":
                            let ac = UIAlertController(title: "It's the restroom", message: "No need to checkin the restroom", preferredStyle: .Alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            presentViewController(ac, animated: true, completion: nil)
                        case "-2":
                            let ac = UIAlertController(title: "It's an elevator", message: "No need to checkin the elevator", preferredStyle: .Alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            presentViewController(ac, animated: true, completion: nil)
                        default: performSegueWithIdentifier("checkin", sender: oneRoom.accessibilityIdentifier)

                }
                }
            } else {
                //do nothing
            }
        }
        
    }
    
    func loadFloor(floor: Int) {
        if floor == 0 {
            return
        }
        let floorWidth = floorView.frame.width
        let floorHeight = floorView.frame.height
        let roomHeight = (floorHeight-10)/4-5
        let roomWidth = (floorWidth-10)/6-5
        if let floorPath = NSBundle.mainBundle().pathForResource("floor\(floor)", ofType: "txt") {
            if let floorString = try? String(contentsOfFile: floorPath, usedEncoding: nil) {
                let lines = floorString.componentsSeparatedByString("\n")
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: (roomWidth+5)*CGFloat(column)+5, y: (roomHeight+5)*CGFloat(row)+5)//+floorView.frame.origin.y)
                        let roomView = UIView(frame: CGRect(origin: position, size: CGSize(width: roomWidth, height: roomHeight)))
                        let roomNumber = UILabel(frame: CGRect(origin: CGPoint(x: 2, y: 2), size: CGSize(width: roomWidth-5, height: 10)))
                        roomNumber.text = "\(floor)\(row)\(column)"//should read from table
                        roomNumber.textAlignment = .Right
                        roomNumber.font = roomNumber.font.fontWithSize(8)
                        if letter == "s" {
                            roomView.backgroundColor =  UIColor.greenColor()//UIColor(patternImage: UIImage(named: "study.png")!)
                            //print("found study")
                            if let roomInfo = allRoomData[roomNumber.text!] as? NSDictionary {
                                if let accomodationStr = roomInfo["capacity"] as? String {//read in from database
                                //let chair = UIImage(named: "chair")
                                    if let accomodation = Int(accomodationStr) {
                                        for i in 0 ..< accomodation {
                                            let chairView = UIImageView(frame: CGRect(origin: CGPoint(x: 6*i+1, y: 12), size: CGSize(width: 5, height: 10)))
                                            //chairView.image = chair
                                            chairView.backgroundColor = UIColor.purpleColor()
                                            roomView.addSubview(chairView)
                                        }
                                    }
                                }
                                //print(allRoomData[roomNumber.text!])
                                if let isOccupied = roomInfo["occupied"] as? String {
                                    if isOccupied == "1" {
                                        roomView.backgroundColor = UIColor.redColor()
                                    }
                                }
                                let availableTill = UILabel(frame: CGRect(origin: CGPoint(x: 2, y: roomView.frame.size.height - 10), size: CGSize(width: roomWidth, height: 10)))
                                if let stayTimeStr = roomInfo["stayTime"] as? String {
                                    if let checkinTimeStr = roomInfo["checkinTime"] as? String {
                                        if checkinTimeStr == "-1" {
                                            availableTill.text = "Available Now"
                                        } else {
                                            let checkinTime = convertStringtoDate(checkinTimeStr)
                                            let stayTime = Int(stayTimeStr)!
                                            let calendar = NSCalendar.currentCalendar()
                                            let components = NSDateComponents()
                                            components.minute = stayTime
                                            let timeToLeave = calendar.dateByAddingComponents(components, toDate: checkinTime, options: [])
                                            
                                            let comp = calendar.components([.Month, .Day, .Hour, .Minute], fromDate: timeToLeave!)
                                            let month = comp.month
                                            let day = comp.day
                                            let hour = comp.hour
                                            let minutes = comp.minute
                                            availableTill.text = "Till \(hour):\(minutes) (\(month)/\(day))"//should read from database
                                        }
                                        availableTill.textAlignment = .Left
                                        availableTill.font = availableTill.font.fontWithSize(8)
                                    }
                                }
                                roomView.addSubview(roomNumber)
                                roomView.addSubview(availableTill)
                                roomView.accessibilityIdentifier = roomNumber.text!

                            }
                        } else if letter == "r" {
                            let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                            let roomImage = UIImage(named: "restroom.png")
                            roomImageView.image = roomImage
                            roomView.addSubview(roomImageView)
                            roomView.accessibilityIdentifier = "-1"
                            //roomView.backgroundColor =  UIColor(patternImage: UIImage(named: "logo.png")!)
                        } else if letter == "e" {
                            let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                            let roomImage = UIImage(named: "elevator.png")
                            roomImageView.image = roomImage
                            roomView.addSubview(roomImageView)
                            roomView.accessibilityIdentifier = "-2"

                        } else {
                            continue
                        }
                        floorView.addSubview(roomView)
                        //print("added roomview to floorview")
                    }
                }
            }
        }
    }
    
    func readAllFromDatabase() {
        //UIView.animateWithDuration(2, animations: { () -> Void in
        //    self.spinner?.startAnimating()
        //})
        spinner?.startAnimating()
        allRoomData.removeAllObjects()
        let url = NSURL(string: "http://\(serverURL)/rooms")
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) { [unowned self] ()->Void in
            if let response = readAllRoomsFromDatabase(url!) {
                for oneRoomInfo in response {
                    if let oneRoomInfoDictionary = oneRoomInfo as? NSDictionary {
                        if let key = oneRoomInfoDictionary["roomNumber"] as? String {
                            //print("key:\(key)")
                            self.allRoomData.setValue(oneRoomInfoDictionary, forKey: key)
                        }
                    }
                }
            }
            //print("allRoomData: \(self.allRoomData)")
            /*
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(1, delay: 5, options: [], animations: { () -> Void in
                    self.spinner?.stopAnimating()
                    }, completion: nil)
            }
            */
        }
    }
    
    func openLink(link: String) {
        var requestUrl: NSURL?
        switch link {
            case "RPIHome":
                requestUrl = NSURL(string: "http://www.rpi.edu")
            case "RensSearch":
                requestUrl = NSURL(string: "http://library.rpi.edu/update.do?artcenterkey=27")
            case "Transportation":
                requestUrl = NSURL(string: "http://www.rpi.edu/dept/parking/shuttle.html")
        default: break
        }
        if requestUrl != nil {
            UIApplication.sharedApplication().openURL(requestUrl!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print(userDefault.stringForKey("numberOfRoomCheckedIn"))
        let roomNumber = sender as? String
        if let dvc = segue.destinationViewController as? CheckinViewController {
            if segue.identifier == "checkin" {
                resetNumberOfRoomCheckedIn()
                dvc.roomNumber = roomNumber
            }
        } else if let dvc = segue.destinationViewController as? addTimeViewController {
            if segue.identifier == "addTime" {
                dvc.roomNumber = roomNumber
            }
        }
    }
    
    func removeAllRoomsFromCurrentFloor() {//including floorView
        for oneView in floorView.subviews {
            oneView.removeFromSuperview()
        }
        //floorView.removeFromSuperview()
    }

}

