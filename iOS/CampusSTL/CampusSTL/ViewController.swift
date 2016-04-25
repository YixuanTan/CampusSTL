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
                    "numberOfRoomCheckedIn:"0",
                    "expireTime":"0"]
*/

//should delete countdown(), in viewdidload add a snippet to see if time is out: when timer didset, set a future date by adding timer to current date, when view did load check if surpasses this future date. If it is, show time is up alert.
//infinite count down
import UIKit
import SpriteKit

var serverURL = "" //"192.168.0.100"//"192.168.0.103:3000"
var expireTime: NSDate!
var timer = -1 {
    didSet {
        if timer > 0 {
            let notification1: UILocalNotification = UILocalNotification()
            let notification2: UILocalNotification = UILocalNotification()
            notification1.category = "News and Sports"
            notification1.alertBody = "\(CONSTANTS.alertTimeLeft) minutes left!"
            notification1.alertAction = "check out or add time"
            notification1.soundName = UILocalNotificationDefaultSoundName
            notification2.category = "News and Sports"
            notification2.alertBody = "Time is up. You have been checked out."
            notification2.soundName = UILocalNotificationDefaultSoundName
            //notification2.alertAction = ""
            
            let date1 = NSDate().dateByAddingTimeInterval(Double(timer-CONSTANTS.alertTimeLeft)*60.0)
            let date2 = NSDate().dateByAddingTimeInterval(Double(timer)*60.0)
            notification1.fireDate = date1
            notification2.fireDate = date2
            UIApplication.sharedApplication().scheduleLocalNotification(notification1)
            UIApplication.sharedApplication().scheduleLocalNotification(notification2)
            expireTime = date2
        }
    }
}

var TIMEABOUTTOEXPIRE = false

class ViewController: UIViewController, UIScrollViewDelegate {
    var testServerURL = "" {
        didSet {
            serverURL = testServerURL
            continueLoading()
        }
    }
    let userDefault = NSUserDefaults.standardUserDefaults()
    var numberOfRoomCheckedIn = 0
    var checkedInRoomId = "0"//in checkedInRoom
    var clock = NSTimer()
    var floorButtons: [UIButton]!
    var allRoomData = NSMutableDictionary()//Dictionary<String, Dictionary<String, String> >()//roomNumber:[field: value]
    var floorShowing = 1
    var filter = Filter.getFilterInstance()
    
    @IBOutlet weak var floorView: UIView!
    
    @IBOutlet weak var RINLabel: UILabel!
    @IBAction func linkTapped(sender: UIButton) {
        openLink(sender.titleLabel!.text!)
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = floorView.frame.size
            scrollView.delegate = self //declare delegation
            scrollView.maximumZoomScale = 2
            scrollView.minimumZoomScale = 1
        }

    }
    
    
    @IBOutlet weak var floorViewRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBAction func filterButtonTapped(sender: UIBarButtonItem) {
    }
    @IBAction func filterButton(sender: UIBarButtonItem) {
    }
    
    @IBOutlet weak var floorOneButton: UIButton!
    @IBOutlet weak var floorTwoButton: UIButton!
    @IBOutlet weak var floorThreeButton: UIButton!
    @IBOutlet weak var floorFourButton: UIButton!
    
    @IBAction func floorButtonTapped(sender: UIButton) {
        switch sender.titleLabel!.text! {
            case "Floor 1":
                floorShowing = 1
            case "Floor 2":
                floorShowing = 2
            case "Floor 3":
                floorShowing = 3
            case "Floor 4":
                floorShowing = 4
            default: break
        }
        refresh()
        for oneFloorButton in floorButtons! {
            oneFloorButton.backgroundColor = UIColor.whiteColor()
            oneFloorButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
        sender.backgroundColor = UIColor.grayColor()
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    @IBAction func refresh() {
        removeAllRoomsFromCurrentFloor()
        readAllFromDatabase()
        while allRoomData.allKeys.count==0 {}
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.2), target: self, selector: #selector(ViewController.stopSpinner), userInfo: nil, repeats: false)
        loadFloor(floorShowing)
        updateRINLabel()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(floorView)
        floorView.backgroundColor =  UIColor.grayColor()//UIColor(patternImage: UIImage(named: "chair.png")!)
        loadServerURLAlertForTesting()
        //continueLoading()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.filterButtonTapped as (ViewController) -> () -> ()))
    }
    
    func continueLoading() {
        readAllFromDatabase()//should update data every 1min or so
        floorButtons = [floorOneButton, floorTwoButton, floorThreeButton, floorFourButton]
        if let numberOfRoomCheckedInStr = userDefault.stringForKey("numberOfRoomCheckedIn") {
            numberOfRoomCheckedIn = Int(numberOfRoomCheckedInStr)!
        }
        if let roomNumber = userDefault.stringForKey("checkedInRoomId") {
            checkedInRoomId = roomNumber
        }
        if userDefault.stringForKey("expireTime") != nil {
            expireTime = convertStringtoDate(userDefault.stringForKey("expireTime")!)
        }
        if userDefault.stringForKey("TIMEABOUTTOEXPIRE") != nil {
            TIMEABOUTTOEXPIRE = userDefault.stringForKey("TIMEABOUTTOEXPIRE")!.toBool()!
        }
        /*
        if let timeRemaining = userDefault.stringForKey("timeRemaining") {
            timer = Int(timeRemaining)!
        }
        */
        //floorButtonTapped(floorButtons[floorShowing-1])
        clock = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown", userInfo: nil, repeats: true)
        refresh()
    }
    
    func loadServerURLAlertForTesting() {
        if serverURL != "" {
            serverURL = serverURL + ":3000"
            return
        }
        let ac = UIAlertController(title: "Server Address", message: "Enter server url for testing", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        ac.addAction(UIAlertAction(title: "Enter", style: .Default, handler: {[unowned self] (action)->Void in
            let textField = ac.textFields![0] as UITextField
            self.testServerURL = "\(textField.text!):3000"
        }))
        presentViewController(ac, animated: true, completion:nil)
    }
    

    func showTimeAboutToExpireAlert() {
        let roomNumber = userDefault.stringForKey("checkedInRoomId")
        let ac = UIAlertController(title: "\(CONSTANTS.alertTimeLeft) minutes left", message: "Please check out or add time", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Check out", style: .Default, handler: {(action)->Void  in
            self.performSegueWithIdentifier("checkin", sender: roomNumber)
        }))
        ac.addAction(UIAlertAction(title: "Add time", style: .Default, handler: {(action)->Void  in
            self.performSegueWithIdentifier("addTime", sender: roomNumber)
        }))
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func showTimeAlreadyExpiredAlert() {
        
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return floorView
    }
    
    func resetNumberOfRoomCheckedIn() {
        //print(userDefault.stringForKey("checkedInRoomId"))
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
    
    override func viewDidAppear(animated: Bool) {
        //print("view did appear")
        super.viewDidAppear(animated)
        //floorButtonTapped(floorButtons[floorShowing-1])
    }
    
    func countDown() {
        //if timer != -1 {
            if expireTime?.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                automaticallyCheckout()
                expireTime = nil
                refresh()
            } else if TIMEABOUTTOEXPIRE == true {
                showTimeAboutToExpireAlert()
                TIMEABOUTTOEXPIRE = false
            }
        //}
    }
    
    func automaticallyCheckout() {
        //yet to implement
        let roomNumber = userDefault.stringForKey("checkedInRoomId")!
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        //print(url)
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
    

    @IBAction func roomDidTapped(sender: UITapGestureRecognizer) {
        //print("touched")
        let touchLocation = sender.locationOfTouch(0, inView: floorView)
        for oneRoom in floorView.subviews {
            let oneRoomFrame = oneRoom.frame//view.convertRect(oneRoom.frame, fromView: )
            if CGRectContainsPoint(oneRoomFrame, touchLocation) {
                let roomNumber = oneRoom.accessibilityIdentifier
                if roomNumber != nil {
                    switch roomNumber! {
                    case "restroom":
                        let ac = UIAlertController(title: "It's the restroom", message: "No need to checkin the restroom", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentViewController(ac, animated: true, completion: nil)
                    case "elevator":
                        let ac = UIAlertController(title: "It's an elevator", message: "No need to checkin the elevator", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentViewController(ac, animated: true, completion: nil)
                    case "food":
                        let ac = UIAlertController(title: "Cafe", message: "Food and drinks are served here!", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentViewController(ac, animated: true, completion: nil)
                    case "entr":
                        let ac = UIAlertController(title: "Library Entrance", message: "Welcome to Folsom Library!", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        presentViewController(ac, animated: true, completion: nil)
                    case "info":
                        let ac = UIAlertController(title: "Front Desk", message: "Borrow books or look for help here", preferredStyle: .Alert)
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
    
    @IBAction func didLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .Began) {
            //print("long pressed")
            let touchLocation = sender.locationOfTouch(0, inView: floorView)
            
            for oneRoom in floorView.subviews {
                let oneRoomFrame = oneRoom.frame
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
        
        

    }
    
    func loadFloor(floor: Int) {
        if floor == 0 {
            return
        }
        scrollView.zoomScale = 1
        let floorWidth = floorView.frame.width
        let floorHeight = floorView.frame.height
        if let floorPath = NSBundle.mainBundle().pathForResource(CONSTANTS.floorPlanFilePrefix+"\(floor)", ofType: "txt") {
            if let floorString = try? String(contentsOfFile: floorPath, usedEncoding: nil) {
                let lines = floorString.componentsSeparatedByString("\n")
                let maxNumberOfRoomsInAColume = CGFloat(lines.count)
                let maxNumberOfRoomsInARow = getLengthOfLongestRowOfMatrix(lines)
                let roomHeight = (floorHeight-4)/maxNumberOfRoomsInAColume-2
                let roomWidth = (floorWidth-4)/maxNumberOfRoomsInARow-2
                for (row, line) in lines.enumerate() {
                    for (column, oneRoomId) in line.componentsSeparatedByString(" ").enumerate() {
                        //construct a room based on the data from the database
                        var oneRoom = constructCurrentRoom(oneRoomId)
                        //check the filter
                        if oneRoom.isStudyRoom() {
                            if filter.checkQualificationOfRoom(oneRoom) == false {
                                continue
                            }
                        }
                        let position = CGPoint(x: (roomWidth+2)*CGFloat(column)+2, y: (roomHeight+2)*CGFloat(row)+2)//+floorView.frame.origin.y)
                        let roomView = UIView(frame: CGRect(origin: position, size: CGSize(width: roomWidth, height: roomHeight)))
                        let roomNumber = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: roomWidth, height: CGFloat(roomHeight/3))))
                        roomNumber.text = oneRoomId//should read from table
                        roomNumber.textAlignment = .Right
                        roomNumber.font = roomNumber.font.fontWithSize(CGFloat(roomHeight/3.5))
                        switch oneRoomId {
                            case "rrrr":
                                let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                                let roomImage = UIImage(named: "restroom.png")
                                roomImageView.image = roomImage
                                roomView.addSubview(roomImageView)
                                roomView.accessibilityIdentifier = "restroom"
                                //roomView.backgroundColor =  UIColor(patternImage: UIImage(named: "logo.png")!)
                            case "eeee":
                                let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                                let roomImage = UIImage(named: "elevator.png")
                                roomImageView.image = roomImage
                                roomView.addSubview(roomImageView)
                                roomView.accessibilityIdentifier = "elevator"
                            case "dddd":
                                break
                            case "xxxx":
                                break
                            case "xxxxx":
                                break
                            case "food":
                                let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                                let roomImage = UIImage(named: "food.png")
                                roomImageView.image = roomImage
                                roomView.addSubview(roomImageView)
                                roomView.accessibilityIdentifier = "food"
                            case "info":
                                let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                                let roomImage = UIImage(named: "frontDesk.png")
                                roomImageView.image = roomImage
                                roomView.addSubview(roomImageView)
                                roomView.accessibilityIdentifier = "info"
                            case "entr":
                                let roomImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: roomView.frame.size))
                                let roomImage = UIImage(named: "entrance.png")
                                roomImageView.image = roomImage
                                roomView.addSubview(roomImageView)
                                roomView.accessibilityIdentifier = "entr"
                            default:
                                roomView.backgroundColor =  UIColor.greenColor()//UIColor(patternImage: UIImage(named: "study.png")!)
                            //print("found study")
                                
                                if let roomInfo = allRoomData[roomNumber.text!] as? NSDictionary {
                                    if let accomodationStr = roomInfo["capacity"] as? String {//read in from database
                                    //let chair = UIImage(named: "chair")
                                        if let accomodation = Int(accomodationStr) {
                                            let chairViewWidth = CGFloat(Int(roomView.frame.size.width/6)-1)
                                            let chairViewHeight = roomView.frame.size.height/CGFloat(4)
                                            for i in 0 ..< accomodation {
                                                let coordX = Int(chairViewWidth)*i+1*(i+1)
                                                let chairView = UIImageView(frame: CGRect(origin: CGPoint(x: coordX, y: Int(chairViewHeight*1.5)), size: CGSize(width: chairViewWidth, height: chairViewHeight)))
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
                                    let availableTill = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: roomHeight - roomHeight/3), size: CGSize(width: roomWidth, height: CGFloat(roomHeight/3))))
                                    if let stayTimeStr = roomInfo["stayTime"] as? String {
                                        if let checkinTimeStr = roomInfo["checkinTime"] as? String {
                                            if checkinTimeStr == "-1" {
                                                availableTill.text = "Avail. Now"
                                            } else {
                                                let checkinTime = convertStringtoDate(checkinTimeStr)
                                                let stayTime = Int(stayTimeStr)!
                                                let calendar = NSCalendar.currentCalendar()
                                                let components = NSDateComponents()
                                                components.minute = stayTime
                                                let timeToLeave = calendar.dateByAddingComponents(components, toDate: checkinTime, options: [])
                                                
                                                let comp = calendar.components([.Month, .Day, .Hour, .Minute], fromDate: timeToLeave!)
                                                //let month = comp.month
                                                //let day = comp.day
                                                let hour = comp.hour
                                                let minutes = comp.minute
                                                //availableTill.text = "Till \(hour):\(minutes) (\(month)/\(day))"
                                                availableTill.text = "Till \(hour):\(minutes)"
                                            }
                                            availableTill.textAlignment = .Left
                                            availableTill.font = availableTill.font.fontWithSize(CGFloat(roomWidth)/CGFloat(availableTill.text!.characters.count)*1.8)
                                        }
                                    }
                                    roomView.addSubview(roomNumber)
                                    roomView.addSubview(availableTill)
                                    roomView.accessibilityIdentifier = roomNumber.text!
                                }
                        }
                        floorView.addSubview(roomView)
                    }
                }
            }
        }
    }
    
    func readAllFromDatabase() {
        UIView.animateWithDuration(2, animations: { () -> Void in
            self.spinner?.startAnimating()
        })
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
    
    func constructCurrentRoom(roomNumber: String) -> Room {
        var oneRoom = Room(roomNumber: roomNumber)
        if let roomInfo = allRoomData[roomNumber] as? NSDictionary {
            if let capacityStr = roomInfo["capacity"] as? String {
                if let capacity = Int(capacityStr) {
                    oneRoom.capacity = capacity
                }
            }
            if let isOccupied = roomInfo["occupied"] as? String {
                if isOccupied == "1" {
                    oneRoom.availability = false
                } else {
                    oneRoom.availability = true
                }
            }
            if let numberOfWindowsStr = roomInfo["numberOfWindows"] as? String {
                if let numberOfWindows = Int(numberOfWindowsStr) {
                    oneRoom.numberOfWindows = numberOfWindows
                }
            }
            if let numberOfBlackboardsStr = roomInfo["numberOfBlackboards"] as? String {
                if let numberOfBlackboards = Int(numberOfBlackboardsStr) {
                    oneRoom.numberOfBlackboards = numberOfBlackboards
                }
            }
            if let numberOfOutletsStr = roomInfo["numberOfOutlets"] as? String {
                if let numberOfOutlets = Int(numberOfOutletsStr) {
                    oneRoom.numberOfOutlets = numberOfOutlets
                }
            }
        }
        return oneRoom
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
        } else if let dvc = segue.destinationViewController as? FilterTableViewController {
            if segue.identifier == "showFilter" {
                
            }
        }
    }
    
    func removeAllRoomsFromCurrentFloor() {//including floorView
        for oneView in floorView.subviews {
            oneView.removeFromSuperview()
        }
        //floorView.removeFromSuperview()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        //print("here")
        if self.view.traitCollection.horizontalSizeClass == .Compact {
            floorView.frame.origin.y = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        if serverURL != "" {
            refresh()
        }
    }
    
    func filterButtonTapped() {
        performSegueWithIdentifier("showFilter", sender: nil)
    }
}

