//
//  BBLSensor.swift
//  Bumbl
//
//  Created by Randy Ting on 1/12/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLSensor: NSObject {
  
// MARK: Constants
  private let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "")
  static private let kDefaultCapSenseThreshold = 50
  
// MARK: Public Variables
  internal var RSSI: NSNumber?
  
// MARK: Private Variables
  private(set) var hasBaby:Bool? {
    get {
      if let _ = capSenseValue {
        return capSenseValue > capSenseThreshold
      } else {
        return false // If no strain gauge value read
      }
    }
    set {
      self.hasBaby = newValue
    }
  }
  
  private let peripheral:CBPeripheral?
  private var capSenseValue:Int?
  private var capSenseThreshold:Int!
  
// MARK: Initialization
  
  // Initializer for instantiating a new bean that is not registered to a parent, but detected by bluetooth radio.
  internal init(withPeripheral peripheral: CBPeripheral!, withCapSenseThreshold capSenseThreshold: Int) {
    self.peripheral = peripheral
    self.capSenseThreshold = capSenseThreshold
    super.init()
    
    peripheral.delegate = self
    
    // TODO: Start timer to poll for RSSI on connection.  Stop timer on disconnect.
  }
  
// MARK: Class Methods 
  
  // Class initializer for instantating an existing peripheral loaded from the server or persistent storage.
  class func sensorWith(peripheral: CBPeripheral?, fromJSONDictionary dictionary: NSDictionary) -> BBLSensor {
    //TODO: Parse JSON and initialize values
    let capSenseThreshFromJSON = 30
    return BBLSensor.init(withPeripheral: peripheral, withCapSenseThreshold: capSenseThreshFromJSON)
  }
  
  // Class initializer for instantating a sensor from connection.
  class func sensorWith(peripheral: CBPeripheral!) -> BBLSensor {
    return BBLSensor.init(withPeripheral: peripheral, withCapSenseThreshold: kDefaultCapSenseThreshold)
  }
  
}

// MARK: CBPeripheralDelegate

extension BBLSensor: CBPeripheralDelegate {
  
  internal func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    let uuid = characteristic.UUID
    
    if uuid == kCapSenseValueCharacteristicUUID {
      var value = 0
      characteristic.value?.getBytes(&value, length: sizeof(Int))
      capSenseValue = value
    }
  }
  
  internal func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
    // TODO: Check to see if this still works
    RSSI = peripheral.RSSI
  }
  
}

