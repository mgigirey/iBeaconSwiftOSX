//
//  ViewController.swift
//  iBeaconSwiftOSX
//
//  Created by Marcelo Gigirey on 11/9/14.
//  Copyright (c) 2014 Marcelo Gigirey. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Cocoa
import Foundation
import CoreBluetooth

class ViewController: NSViewController, CBTransmitterDelegate {
    // Properties
    var isAdvertising: Bool?
    //var isReadyForAdvertising : Bool?
    var transmitter : CBBeaconTransmitter?
    
    // Constants
    let kCBUserDefaultsUDID = "kCBUserDefaultsUDID"
    let kCBCUserDefaultsMajor = "kCBCUserDefaultsMajor"
    let kCBCUserDefaultsMinor = "kCBCUserDefaultsMinor"
    let kCBCUserDefaultsMeasuredPower = "kCBCUserDefaultsMeasuredPower"
    
    @IBOutlet weak var uuidTextField: NSTextFieldCell!
    @IBOutlet weak var majorTextField: NSTextField!
    @IBOutlet weak var minorTextField: NSTextField!
    @IBOutlet weak var measuredPowerTextField: NSTextField!
    @IBOutlet weak var generateUUIDButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAdvertising = false
        //isReadyForAdvertising = false
        
        transmitter = CBBeaconTransmitter()
        transmitter?.delegate = self
        
        // Retrieve Values from NSUserDefaults
        loadUserDefaults()
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func loadUserDefaults() {
        var udid : NSString? = NSUserDefaults.standardUserDefaults().stringForKey(kCBUserDefaultsUDID)
        if udid != nil {
            uuidTextField.stringValue = "\(udid!)"
        }
        
        var major : NSString? = NSUserDefaults.standardUserDefaults().stringForKey(kCBCUserDefaultsMajor)
        if major != nil {
            majorTextField.stringValue = "\(major!)"
        }
        
        var minor : NSString? = NSUserDefaults.standardUserDefaults().stringForKey(kCBCUserDefaultsMinor)
        if minor != nil {
            minorTextField.stringValue = "\(minor!)"
        }
        
        var measuredPower : NSString? = NSUserDefaults.standardUserDefaults().stringForKey(kCBCUserDefaultsMeasuredPower)
        if measuredPower != nil {
            measuredPowerTextField.stringValue = "\(measuredPower!)"
        }
    }
    
    @IBAction func startButtonClicked(sender: AnyObject) {
        // Transmit
        if !isAdvertising! {
            // Store Values in NSUserDefaults
            NSUserDefaults.standardUserDefaults().setObject(uuidTextField.stringValue, forKey: kCBUserDefaultsUDID)
            NSUserDefaults.standardUserDefaults().setObject(majorTextField.stringValue, forKey: kCBCUserDefaultsMajor)
            NSUserDefaults.standardUserDefaults().setObject(minorTextField.stringValue, forKey: kCBCUserDefaultsMinor)
            NSUserDefaults.standardUserDefaults().setObject(measuredPowerTextField.stringValue, forKey: kCBCUserDefaultsMeasuredPower)
            
            transmitAsBeacon()
        }
        else {
            stopBeacon()
        }
    }
    
    @IBAction func genereateUUIDClicked(sender: AnyObject) {
        uuidTextField.stringValue = "\(NSUUID().UUIDString)"
    }
    
    // Transmit as iBeacon
    func transmitAsBeacon() {
        transmitter?.setUpBeacon(proximityUUID: NSUUID(UUIDString: uuidTextField.stringValue)!,
            major: UInt16(majorTextField.integerValue),
            minor: UInt16(minorTextField.integerValue),
            measuredPower: Int8(measuredPowerTextField.integerValue))
        transmitter?.startTransmitting()
    }
    
    func stopBeacon() {
        transmitter?.stopTransmitting()
    }
    
    func toggleControls(beaconStatus: BeaconStatus) {
        switch beaconStatus
        {
        case .Advertising:
            startButton.title = "Turn iBeacon off"
            startButton.enabled = true
            enableControls(false)
        case .NotAdvertising:
            startButton.title = "Turn iBeacon on"
            startButton.enabled = true
            enableControls(true)
        case .ResumeAdvertise:
            transmitAsBeacon()
            startButton.enabled = true
            enableControls(false)
        case .CannotAdvertise:
            startButton.enabled = false
            enableControls(false)
        }
    }
    
    func enableControls(enabled: Bool) {
        generateUUIDButton.enabled = enabled
        uuidTextField.enabled = enabled
        majorTextField.enabled = enabled
        minorTextField.enabled = enabled
        measuredPowerTextField.enabled = enabled
    }
    
    func transmitterDidPoweredOn(isPoweredOn: Bool) {
        if isPoweredOn {
            toggleControls(isAdvertising! ? BeaconStatus.ResumeAdvertise : BeaconStatus.NotAdvertising)
        }
        else {
            toggleControls(BeaconStatus.CannotAdvertise)
        }
    }
    
    func transmitterDidStartAdvertising(isAdvertising: Bool) {
        self.isAdvertising = isAdvertising
        toggleControls(isAdvertising == true ? BeaconStatus.Advertising : BeaconStatus.NotAdvertising)
    }
    
    enum BeaconStatus {
        case Advertising
        case NotAdvertising
        case ResumeAdvertise
        case CannotAdvertise
    }
}