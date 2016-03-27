//
//  BBLSensorManager.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import CoreBluetooth


@objc protocol BBLSensorManagerDelegate {
  // TODO: Use these delegate methods to update the connection statuses of the parent's sensors
  optional func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor)
  optional func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor)
  optional func sensorManager(sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor)
  optional func sensorManager(sensorManager: BBLSensorManager, didAttemptToScanWhileBluetoothRadioIsOff isBluetoothRadioOff: Bool)
  optional func sensorManager(sensorManager: BBLSensorManager, didFailToConnectToSensor sensor: BBLSensor)
}

class BBLSensorManager: NSObject {
  
  // MARK: Public Variables
  
  internal var connectedSensors = Set<BBLSensor>()
  internal var discoveredSensors = Set<BBLSensor>()
  internal weak var profileSensors:NSMutableSet!
  internal var state: CBCentralManagerState {
    get{
      return centralManager.state
    }
  }
  
  // MARK: Private Variables
  private let delegates = NSHashTable.weakObjectsHashTable()
  private let centralManager:CBCentralManager!
  private var disconnectAllSensorsCompletionBlock: (()->())?
  
  // MARK: Initialization
  
  internal init(withCentralManager centralManager: CBCentralManager!,
    withProfileSensors profileSensors:NSMutableSet?) {
      
      self.centralManager = centralManager
      if let profileSensors = profileSensors {
        self.profileSensors = profileSensors
      } else {
        self.profileSensors = NSMutableSet()
      }
      super.init()
      
      centralManager.delegate = self
  }
  
  // MARK: Delegates
  
  internal func registerDelegate(delegate: BBLSensorManagerDelegate) {
    delegates.addObject(delegate)
  }
  
  internal func unregisterDelegate(delegate: BBLSensorManagerDelegate) {
    delegates.addObject(delegate)
  }
  
  private func callDelegates(callback: (delegate: BBLSensorManagerDelegate) -> ()) {
    delegates.objectEnumerator().forEach({
      let delegate = $0 as! BBLSensorManagerDelegate
      dispatch_async(dispatch_get_main_queue(), {
        callback(delegate: delegate)
      })
    })
  }
  
  // MARK: Access
  
  internal func scanForSensors(){
    guard state == .PoweredOn else {
      callDelegates{$0.sensorManager?(self, didAttemptToScanWhileBluetoothRadioIsOff: true)}
      return
    }
    scanForPeripherals(withCentralManager:centralManager, withServiceUUID: BBLSensorInfo.kSensorServiceUUID)
  }
  
  private func scanForPeripherals(withCentralManager centralManager:CBCentralManager, withServiceUUID serviceUUID: CBUUID){
    if centralManager.state == .PoweredOn {
      centralManager.scanForPeripheralsWithServices([BBLSensorInfo.kSensorServiceUUID], options: nil)
    }
  }
  
  internal func stopScanningForSensors() {
    centralManager.stopScan()
  }
  
  // MARK: Connection
  
  internal func connectToSensor(sensor: BBLSensor!) {
    centralManager.connectPeripheral(sensor.peripheral!, options: nil)
  }
  
  internal func disconnectSensor(sensor: BBLSensor!) {
    
    guard let peripheral = sensor.peripheral else {
        return
    }
    
    centralManager.cancelPeripheralConnection(peripheral)
  }
  
  internal func disconnectAllProfileSensorsWithCompletion(completion:()->() ) {
    
    if connectedSensors.count == 0 {
      completion()
      return
    }
    
    disconnectAllSensorsCompletionBlock = completion
    for sensor in profileSensors {
      disconnectSensor(sensor as! BBLSensor)
    }
  }
  
}

// MARK: CBCentralManagerDelegate

extension BBLSensorManager: CBCentralManagerDelegate {
  
  internal func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    
    scanForSensors()
    
    if let profileSensors = profileSensors where profileSensors.count != 0 {
      for sensor in profileSensors {
        if sensor.peripheral == peripheral {
          connectedSensors.insert(sensor as! BBLSensor)
          (sensor as! BBLSensor).onDidConnect()
          callDelegates{$0.sensorManager?(self, didConnectSensor: sensor as! BBLSensor)}
          return
        }
      }
    }
    
    for sensor in discoveredSensors {
      if sensor.peripheral == peripheral {
        discoveredSensors.remove(sensor)
        connectedSensors.insert(sensor)
        sensor.onDidConnect()
        callDelegates{$0.sensorManager?(self, didConnectSensor: sensor)}
        return
      }
    }
  }
  
  internal func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    
    if let disconnectAllSensorsCompletionBlock = disconnectAllSensorsCompletionBlock
      where connectedSensors.count == 0 {
        disconnectAllSensorsCompletionBlock()
        self.disconnectAllSensorsCompletionBlock = nil
        return
    }
    
    for sensor in connectedSensors {
      if sensor.peripheral == peripheral {
        callDelegates{$0.sensorManager?(self, didDisconnectSensor: sensor)}
        connectedSensors.remove(sensor)
        sensor.onDidDisconnect()
      }
    }
    
    if disconnectAllSensorsCompletionBlock == nil {
      if let profileSensors = profileSensors where profileSensors.count != 0 {
        for sensor in profileSensors {
          if sensor.peripheral == peripheral {
            (sensor as! BBLSensor).connect()
          }
        }
      }
    }
    
  }
  
  internal func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    
    let uuid = peripheral.name
    
    //TODO: Log name and RSSI?
    if let profileSensors = profileSensors where profileSensors.count != 0  {
      for sensor in profileSensors {
        let thisSensor = sensor as! BBLSensor
        if thisSensor.uuid == uuid {
          callDelegates{$0.sensorManager?(self, didDiscoverSensor: thisSensor)}
          thisSensor.sensorManager = self
          thisSensor.peripheral = peripheral
          thisSensor.stateMachine = BBLStateMachine(initialState: .Disconnected, delegate: thisSensor)
          thisSensor.connect()
          return
        }
      }
    }
    
    for sensor in discoveredSensors {
      if sensor.peripheral == peripheral {return}
    }
    
    for sensor in connectedSensors {
      if sensor.peripheral == peripheral {return}
    }
    
    discoveredSensorWithPeripheral(peripheral)
  }
  
  private func discoveredSensorWithPeripheral(peripheral: CBPeripheral) -> Void {
    
    BBLParseAPIClient.queryForExistingBabySensorsWithUUID(peripheral.name!) { (sensors: [BBLSensor]?) in
      
      let discoveredSensor: BBLSensor!
      
      if let sensors = sensors where sensors.count > 0 {
        discoveredSensor = sensors.first
        discoveredSensor.fetchInBackgroundWithBlock({ (result: PFObject?, error: NSError?) in
          
          let discoveredSensor = result as! BBLSensor
          
          if let error = error {
            print(error.localizedDescription)
          } else {
            self.discoveredSensors.insert(discoveredSensor)
            self.callDelegates{$0.sensorManager?(self, didDiscoverSensor: discoveredSensor)}
            discoveredSensor.sensorManager = self
            discoveredSensor.peripheral = peripheral
            discoveredSensor.stateMachine = BBLStateMachine(initialState: .Disconnected, delegate: discoveredSensor)
          }
          
        })
        
      } else {
        discoveredSensor = BBLSensor.sensorWith(peripheral, withSensorManager: self)
        self.discoveredSensors.insert(discoveredSensor)
        self.callDelegates{$0.sensorManager?(self, didDiscoverSensor: discoveredSensor)}
      }
    
    }
    
  }
  
  internal func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
    //TODO
  }
  
  internal func centralManagerDidUpdateState(central: CBCentralManager) {
    if central.state == .PoweredOn {
      scanForSensors()
    } else if central.state == .PoweredOff {
      for sensor in connectedSensors {
        sensor.disconnect()
      }
      connectedSensors.removeAll()
    } else {
      connectedSensors.removeAll()
    }
  }
  
  internal func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    
    for sensor in discoveredSensors {
      if sensor.peripheral == peripheral {discoveredSensors.remove(sensor)}
      callDelegates{$0.sensorManager!(self, didFailToConnectToSensor: sensor)
      }
    }
  }
  
}
