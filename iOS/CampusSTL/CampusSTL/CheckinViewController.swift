//
//  CheckinViewController.swift
//  CampusSTL
//
//  Created by Terry on 3/3/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import UIKit

class CheckinViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let userDefault = NSUserDefaults.standardUserDefaults()
    var numberOfRoomCheckedIn = 0
    @IBOutlet weak var timeLabel: UILabel!
    var roomNumber: String!
    var pickerData:[String]!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var checkinSwitch: UISwitch!
    var stayTime = 0
    var occupied: String!
    var timeChose: Int = 0
    var RIN: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkin Room \(roomNumber)"
        setupPicker()
        myPicker.dataSource = self
        myPicker.delegate = self
        setSwitch()
        if let numberOfRoomCheckedInStr = userDefault.stringForKey("numberOfRoomCheckedIn") {
            numberOfRoomCheckedIn = Int(numberOfRoomCheckedInStr)!
            print("checkinviewcontroller ----------------- \(userDefault)")
            print("checkinviewcontroller ----------------- \(numberOfRoomCheckedIn)")
        }
    }
    
    func setSwitch() {
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        if let roomInfo = readOneRoomFromDatabase(url!) {
            if let isOccupied = roomInfo["occupied"] as? String {
                if isOccupied == "0" {
                    checkinSwitch.setOn(false, animated: true)
                } else {
                    self.checkinSwitch.setOn(true, animated: true)
                }
            }
        } else {
            print("cannot get room info")
        }
    }
    
    var finish = false
    
    @IBAction func checkinSwitchChanged(sender: UISwitch) {
        if sender.on {
            if numberOfRoomCheckedIn == 1 {
                let ac = UIAlertController(title: "Check in failed", message: "You may only check in one room at a time", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "PIN", message: "Please enter your RIN to check in", preferredStyle: .Alert)
                ac.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.text = "RIN"
                })
                ac.addAction(UIAlertAction(title: "Enter", style: .Default, handler: {[unowned self] (action)->Void in
                    let textField = ac.textFields![0] as UITextField
                    self.RIN = textField.text!
                    if self.sendCheckinToServer() {
                        let ac2 = UIAlertController(title: "Check in", message: "You have successfully Checked in with \n RIN: \(self.RIN)", preferredStyle: .Alert)
                        ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                            self.navigationController?.popViewControllerAnimated(true)
                            self.numberOfRoomCheckedIn++
                            self.userDefault.setObject("1", forKey: "numberOfRoomCheckedIn")
                            self.userDefault.setObject(self.roomNumber, forKey: "roomNumber")
                        }))
                        //ac2.addAction(UIAlertAction(title: "Re-enter RIN", style: .Default, handler: {(action)->Void in
                        //    self.checkinSwitch.on = true
                        //}))
                        self.presentViewController(ac2, animated: true, completion: nil)
                    }
                }))
                ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(ac, animated: true, completion: {self.finish = true})
            }
            
        } else {
            let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
            if let roomInfo = readOneRoomFromDatabase(url!) {
                let ac = UIAlertController(title: "Check out", message: "Please enter your RIN to check out", preferredStyle: .Alert)
                ac.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.text = "RIN"
                })
                ac.addAction(UIAlertAction(title: "Enter", style: .Default, handler: {[unowned self] (action)->Void in
                    let textField = ac.textFields![0] as UITextField
                    if (roomInfo["userId"] as! String) != textField.text {
                        let ac2 = UIAlertController(title: "Unable to check out", message: "Please check the RIN you entered", preferredStyle: .Alert)
                        ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }))
                        self.presentViewController(ac2, animated: true, completion: nil)
                        
                    } else {
                        if self.sendUnregisterToServer() {
                            let ac2 = UIAlertController(title: "Check out", message: "You have successfully checked out", preferredStyle: .Alert)
                            ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                                self.navigationController?.popViewControllerAnimated(true)
                                self.numberOfRoomCheckedIn--
                                self.userDefault.setObject("0", forKey: "numberOfRoomCheckedIn")
                                self.userDefault.setObject("0", forKey: "roomNumber")
                            }))
                            self.presentViewController(ac2, animated: true, completion: nil)
                        } else {
                            let ac2 = UIAlertController(title: "Unable to check out", message: "Please wait a second", preferredStyle: .Alert)
                            ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(ac2, animated: true, completion: nil)
                            
                        }
                    }
                }))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
            /*
            let ac = UIAlertController(title: "PIN", message: "Please enter your RIN", preferredStyle: .Alert)
            ac.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = "RIN"
            })
            ac.addAction(UIAlertAction(title: "Enter", style: .Default, handler: {[unowned self] (action)->Void in
                let textField = ac.textFields![0] as UITextField
                self.RIN = textField.text!
                if self.sendUnregisterToServer() {
                    let ac2 = UIAlertController(title: "Unregister", message: "You have successfully unregistered", preferredStyle: .Alert)
                    ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentViewController(ac2, animated: true, completion: nil)
                } else {
                    let ac2 = UIAlertController(title: "Unable to unregister", message: "Please check the RIN you entered", preferredStyle: .Alert)
                    ac2.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac2, animated: true, completion: nil)

                }
                }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: {self.finish = true})
            */
    }
    
    func sendCheckinToServer()->Bool {
        if timeChose == 0 {
            stayTime = 2 // should change back to 30
        }
        
        let parameters = ["roomNumber":roomNumber,"occupied": "1","checkinTime": convertDatetoString(NSDate()),"stayTime": String(stayTime),"userId": RIN] as Dictionary<String, String>
        //print("stayTime: \(stayTime)")
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        //print(url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)//sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error as NSError{
            print("Fail to create json \(error.localizedDescription)")
            return false
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            //if error, return false
        }
        task.resume()
        //checkedInRoomId = self.roomNumber
        userDefault.setObject(self.roomNumber, forKey: "roomNumber")
        timer = stayTime
        return true//should modify
    }
    
    func sendUnregisterToServer()->Bool {
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        let parameters = ["roomNumber":roomNumber,"occupied": "0","checkinTime":"-1","stayTime": "0","userId":RIN] as Dictionary<String, String>
        //print(url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)//sharedSession()
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch let error as NSError{
            print("Fail to create json \(error.localizedDescription)")
            return false
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            //if error, return false
        }
        task.resume()
        //checkedInRoomId = "0"
        userDefault.setObject("0", forKey: "roomNumber")
        timer = -1
        return true//should modified
    }
    
    func setupPicker() {
        pickerData = ["30 min", "1 hour"]
        for i in 2...20 {
            pickerData.append("\(i) hours")
        }
    }
    //MARK: data source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeLabel.text = "Approx. \(pickerData[row]) to stay"
        if row == 0 {
            stayTime = 2//should change back to 30
        } else {
            stayTime = row*60
        }
        timeChose = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
