//
//  BBLSensorManager.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit


@objc protocol BBLSensorManagerDelegate {
  optional func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor)
  optional func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor)
}

class BBLSensorManager: NSObject {
  
// MARK: Public Variables
  internal weak var delegate:BBLSensorManagerDelegate?
  
// MARK: Private Variables
  internal let centralManager:CBCentralManager!
  
// MARK: Initialization
  internal init(withCentralManager centralManager: CBCentralManager!, withDelegate delegate:CBCentralManagerDelegate!) {
    self.centralManager = centralManager
    super.init()
    
    centralManager.delegate = self
  }

}


// MARK: CBCentralManagerDelegate
extension BBLSensorManager: CBCentralManagerDelegate {
  
  internal func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    delegate?.sensorManager?(self, didConnectSensor: BBLSensor.sensorWith(peripheral))
  }
  
  internal func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    //TODO
  }
  
  internal func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    //TODO
  }
  
  internal func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
    //TODO
  }
  
  internal func centralManagerDidUpdateState(central: CBCentralManager) {
    //TODO
  }
  
  internal func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    //TODO
  }
  
}
