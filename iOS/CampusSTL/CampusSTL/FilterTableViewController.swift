//
//  FilterTableViewController.swift
//  CampusSTL
//
//  Created by Terry on 4/21/16.
//  Copyright © 2016 Rensselaer Polytechnic Institute. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {
    var filter = Filter.getFilterInstance()
    
    @IBOutlet weak var capacityStepper: UIStepper!
    @IBOutlet weak var capacityTextField: UITextField! {
        didSet {
            if let lowestCapacity = Int((capacityTextField.text!)) {
                filter.shouldHaveLowestCapacity(lowestCapacity)
            }
        }
    }
    @IBOutlet weak var availableRoomOnlySwitch: UISwitch!
    @IBOutlet weak var hasWindwoSwitch: UISwitch!
    @IBOutlet weak var hasBlackboardSwitch: UISwitch!
    @IBOutlet weak var hasMultipleOutletsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter"
        capacityTextField.text = String(filter.shouldHaveLowestCapacity)
        capacityStepper.value = Double(filter.shouldHaveLowestCapacity)
        availableRoomOnlySwitch.on = filter.availableRoomOnly
        hasWindwoSwitch.on = filter.shouldHaveWindow
        hasBlackboardSwitch.on = filter.shouldHaveBlackboard
        hasMultipleOutletsSwitch.on = filter.shouldHaveMultipleOutlets
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .Done, target: self, action: #selector(FilterTableViewController.clearAll))
    }
    
    func clearAll() {
        capacityTextField.text! = "0";
        availableRoomOnlySwitch.on = false
        hasWindwoSwitch.on = false
        hasBlackboardSwitch.on = false
        hasMultipleOutletsSwitch.on = false
        
        filter.clearAll()
    }
    
    @IBAction func capacityStepperDidChange(sender: UIStepper) {
        capacityTextField.text = String(Int(capacityStepper.value))
        filter.shouldHaveLowestCapacity(Int(capacityStepper.value))
    }
    
    @IBAction func availableRoomOnlySwitchDidChange(sender: UISwitch) {
        if sender.on {
            filter.availableRoomOnly(true)
        } else {
            filter.availableRoomOnly(false)
        }
    }
    
    @IBAction func hasWindwoSwitchDidChange(sender: UISwitch) {
        if sender.on {
            filter.shouldHaveWindow(true)
        } else {
            filter.shouldHaveWindow(false)
        }
    }
    
    @IBAction func hasBlackboardSwitchDidChange(sender: UISwitch) {
        if sender.on {
            filter.shouldHaveBlackboard(true)
        } else {
            filter.shouldHaveBlackboard(false)
        }
    }
    
    
    @IBAction func hasMultipleOutlets(sender: UISwitch) {
        if sender.on {
            filter.shouldHaveMultipleOutlets(true)
        } else {
            filter.shouldHaveMultipleOutlets(false)
        }
    }
    
    
    
    
    
}
