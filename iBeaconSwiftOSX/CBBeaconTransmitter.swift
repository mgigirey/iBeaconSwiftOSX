//
//  CBBeaconTransmitter.swift
//  iBeaconSwiftOSX
//
//  Created by Marcelo Gigirey on 11/5/14.
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

import Foundation
import CoreBluetooth
import CoreLocation

private var once = dispatch_once_t()

final class CBBeaconTransmitter: NSObject, CBBeaconTransmitterProtocol {
    // Properties
    var manager: CBPeripheralManager!
    var beaconData: CBBeaconAvertisementData!
    var delegate: CBTransmitterDelegate?
    
    override init() {
        super.init()
        // http://stackoverflow.com/a/24137213/3824765
        dispatch_once(&once) {
            self.manager = CBPeripheralManager(delegate: self, queue: nil)
        }
    }
    
    // Set Up
    func setUpBeacon(proximityUUID uuid: NSUUID?, major M: CLBeaconMajorValue?, minor m: CLBeaconMinorValue?, measuredPower power: Int8?) {
        beaconData = CBBeaconAvertisementData(proximityUUID: uuid!, major: M!, minor: m!, measuredPower: power!)
    }
    
    // Transmitting
    func startTransmitting() {
        if let advertisement = beaconData.beaconAdvertisement() {
            print(advertisement)
            manager.startAdvertising(advertisement as? [String : AnyObject])
        }
    }
    
    func stopTransmitting() {
        manager.stopAdvertising()
        //manager.delegate = nil
        delegate?.transmitterDidStartAdvertising(false)
        print("Advertising our iBeacon Stopped")
    }
    
    
    // CBPeripheralManager Delegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("The peripheral state is ", terminator: "")
        switch peripheral.state {
        case .PoweredOff:
            print("Powered off")
        case .PoweredOn:
            print("Powered on")
        case .Resetting:
            print("Resetting")
        case .Unauthorized:
            print("Unauthorized")
        case .Unknown:
            print("Unknown")
        case .Unsupported:
            print("Unsupported")
        }
        
        let isPoweredOn = peripheral.state == CBPeripheralManagerState.PoweredOn ? true : false
        delegate?.transmitterDidPoweredOn(isPoweredOn)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error == nil {
            print("Advertising our iBeacon Started")
            delegate?.transmitterDidStartAdvertising(true)
        } else {
            print("Failed to advertise iBeacon. Error = \(error)")
            delegate?.transmitterDidStartAdvertising(false)
        }
    }
}
