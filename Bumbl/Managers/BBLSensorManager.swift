//
//  BBLSensorManager.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit


@objc protocol BBLSensorManagerDelegate {
  // TODO: Use these delegate methods to update the connection statuses of the parent's sensors
  optional func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor)
  optional func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor)
}

class BBLSensorManager: NSObject {
  
// MARK: Constants
  private let kSensorServiceUUID = CBUUID.init(string: "")
  
// MARK: Public Variables
  internal weak var delegate:BBLSensorManagerDelegate?
  internal var connectedSensors = Set<BBLSensor>()
  internal var discoveredSensors = Set<BBLSensor>()
  
// MARK: Private Variables
  internal let centralManager:CBCentralManager!
  
// MARK: Initialization
  internal init(withCentralManager centralManager: CBCentralManager!, withDelegate delegate:CBCentralManagerDelegate!) {
    self.centralManager = centralManager
    super.init()
    
    centralManager.delegate = self
  }
  
// MARK: Access
  internal func scanForSensors(){
    scanForPeripherals(withCentralManager:centralManager, withServiceUUID: kSensorServiceUUID)
  }
  
  private func scanForPeripherals(withCentralManager centralManager:CBCentralManager, withServiceUUID serviceUUID: CBUUID){
    if centralManager.state == .PoweredOn {
      centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
    }
  }
  
  internal func stopScanningForSensors() {
    centralManager.stopScan()
  }

}


// MARK: CBCentralManagerDelegate
extension BBLSensorManager: CBCentralManagerDelegate {
  
  internal func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    let connectedSensor = BBLSensor.sensorWith(peripheral)
    delegate?.sensorManager?(self, didConnectSensor: connectedSensor)
    discoveredSensors.remove(connectedSensor)
    connectedSensors.insert(connectedSensor)
  }
  
  internal func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    let disconnectedSensor = BBLSensor.sensorWith(peripheral)
    connectedSensors.remove(disconnectedSensor)
  }
  
  internal func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    //TODO: Log name and RSSI?
    let discoveredSensor = BBLSensor.sensorWith(peripheral)
    discoveredSensors.insert(discoveredSensor)
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
