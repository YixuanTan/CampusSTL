//
//  addTimeViewController.swift
//  CampusSTL
//
//  Created by Terry on 3/12/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import UIKit

class addTimeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerData:[String]!
    var timeToAdd = 10
    var roomNumber: String!
    var myPickerChosenRowValue = "10 min"
    @IBOutlet weak var myPicker: UIPickerView!
    
    @IBAction func addButtonTapped(sender: UIButton) {
        let url = NSURL(string: "http://\(serverURL)/rooms/\(roomNumber)")
        if let myRoom = readOneRoomFromDatabase(url!) {
            print("here")
            let timeToStayStr = myRoom["stayTime"] as! String
            let timeToStay = Int(timeToStayStr)
            let newTimeToStay = timeToStay! + timeToAdd
            let parameters = ["stayTime": String(newTimeToStay)] as Dictionary<String, String>
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
            timer += timeToAdd
            let ac = UIAlertController(title: "Time added", message: "You have added \(myPickerChosenRowValue)", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action)->Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Please Add More Time"
        setupPicker()
        myPicker.dataSource = self
        myPicker.delegate = self
    }
    
    func setupPicker() {
        pickerData = ["10 min", "30 min", "1 hour"]
        for i in 3...19 {
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
        myPickerChosenRowValue = pickerData[row]
        if row == 0 {
            timeToAdd = 10
        } else if row == 1 {
            timeToAdd = 30
        } else {
            timeToAdd = (row-1)*60
        }
    }

    
}
