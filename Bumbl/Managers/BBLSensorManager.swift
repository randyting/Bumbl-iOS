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
  @objc optional func sensorManager(_ sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor)
  @objc optional func sensorManager(_ sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor)
  @objc optional func sensorManager(_ sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor)
  @objc optional func sensorManager(_ sensorManager: BBLSensorManager, didAttemptToScanWhileBluetoothRadioIsOff isBluetoothRadioOff: Bool)
  @objc optional func sensorManager(_ sensorManager: BBLSensorManager, didFailToConnectToSensor sensor: BBLSensor)
}

class BBLSensorManager: NSObject {
  
  // MARK: Public Variables
  
  internal var peripheralsToDiscoverServices = Set<CBPeripheral>()
  internal var connectedSensors = Set<BBLSensor>()
  internal var discoveredSensors = Set<BBLSensor>()
  internal weak var profileSensors:NSMutableSet!
  internal var state: CBManagerState {
    get{
      return centralManager.state
    }
  }
  
  internal var centralManager: CBCentralManager!
  
  // MARK: Private Variables
  fileprivate let delegates: NSHashTable<AnyObject>  = NSHashTable.weakObjects()
  fileprivate var disconnectAllSensorsCompletionBlock: (()->())?
  
  // MARK: Initialization
  
  internal init(withProfileSensors profileSensors:NSMutableSet?) {
    
    if let profileSensors = profileSensors {
      self.profileSensors = profileSensors
    } else {
      self.profileSensors = NSMutableSet()
    }
    super.init()
  }
  
  // MARK: Delegates
  
  internal func registerDelegate(_ delegate: BBLSensorManagerDelegate) {
    delegates.add(delegate)
  }
  
  internal func unregisterDelegate(_ delegate: BBLSensorManagerDelegate) {
    delegates.remove(delegate)
  }
  
  fileprivate func callDelegates(_ callback: @escaping (_ delegate: BBLSensorManagerDelegate) -> ()) {
    delegates.objectEnumerator().forEach({
      let delegate = $0 as! BBLSensorManagerDelegate
      DispatchQueue.main.async(execute: {
        callback(delegate)
      })
    })
  }
  
  // MARK: Access
  
  internal func scanForSensors(){
    guard state == .poweredOn else {
      callDelegates{$0.sensorManager?(self, didAttemptToScanWhileBluetoothRadioIsOff: true)}
      return
    }
    scanForPeripherals(withCentralManager:centralManager, withServiceUUID: BBLSensorInfo.kSensorServiceUUID)
  }
  
  fileprivate func scanForPeripherals(withCentralManager centralManager:CBCentralManager, withServiceUUID serviceUUID: CBUUID){
    if centralManager.state == .poweredOn {
      centralManager.scanForPeripherals(withServices: [BBLSensorInfo.kSensorServiceUUID], options: nil)
    }
  }
  
  internal func stopScanningForSensors() {
    centralManager.stopScan()
  }
  
  // MARK: Connection
  
  internal func connectToSensor(_ sensor: BBLSensor!) {
    centralManager.connect(sensor.peripheral!, options: nil)
  }
  
  internal func disconnectSensor(_ sensor: BBLSensor!) {
    
    guard let peripheral = sensor.peripheral else {
      return
    }
    
    centralManager.cancelPeripheralConnection(peripheral)
  }
  
  internal func disconnectAllProfileSensorsWithCompletion(_ completion:@escaping ()->() ) {
    
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
  
  internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    
    scanForSensors()
    
    if let profileSensors = profileSensors , profileSensors.count != 0 {
      for sensor in profileSensors {
        if let currentPeripheral = (sensor as! BBLSensor).peripheral , currentPeripheral == peripheral {
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
  
  internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
    if let disconnectAllSensorsCompletionBlock = disconnectAllSensorsCompletionBlock
      , connectedSensors.count == 0 {
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
      if let profileSensors = profileSensors , profileSensors.count != 0 {
        for sensor in profileSensors {
          if let currentPeripheral = (sensor as! BBLSensor).peripheral , currentPeripheral == peripheral {
            (sensor as! BBLSensor).connect()
          }
        }
      }
    }
    
  }
  
  internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    let uuid = peripheral.name
    
    //TODO: Log name and RSSI?
    if let profileSensors = profileSensors , profileSensors.count != 0  {
      for sensor in profileSensors {
        let thisSensor = sensor as! BBLSensor
        if thisSensor.uuid == uuid {
          callDelegates{$0.sensorManager?(self, didDiscoverSensor: thisSensor)}
          thisSensor.sensorManager = self
          thisSensor.peripheral = peripheral
          thisSensor.stateMachine = BBLStateMachine(initialState: .disconnected, delegate: thisSensor)
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
  
  fileprivate func discoveredSensorWithPeripheral(_ peripheral: CBPeripheral) -> Void {
    
    BBLParseAPIClient.queryForExistingBabySensorsWithUUID(peripheral.name!) { (sensors: [BBLSensor]?) in
      
      let discoveredSensor: BBLSensor!
      
      if let sensors = sensors , sensors.count > 0 {
        discoveredSensor = sensors.first
        discoveredSensor.fetchInBackground(block: { (result: PFObject?, error: Error?) in
          
          let discoveredSensor = result as! BBLSensor
          
          if let error = error {
            print(error.localizedDescription)
          } else {
            self.discoveredSensors.insert(discoveredSensor)
            self.callDelegates{$0.sensorManager?(self, didDiscoverSensor: discoveredSensor)}
            discoveredSensor.sensorManager = self
            discoveredSensor.peripheral = peripheral
            discoveredSensor.stateMachine = BBLStateMachine(initialState: .disconnected, delegate: discoveredSensor)
          }
          
        })
        
      } else {
        discoveredSensor = BBLSensor.sensorWith(peripheral, withSensorManager: self)
        self.discoveredSensors.insert(discoveredSensor)
        self.callDelegates{$0.sensorManager?(self, didDiscoverSensor: discoveredSensor)}
      }
      
    }
    
  }
  
  internal func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    
    let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]
    
    guard let savedPeripherals = peripherals else {
      fatalError("Central Manager restored without peripherals")
    }
    
    for peripheral in savedPeripherals {
      
      let uuid = peripheral.name
      
      if let profileSensors = profileSensors , profileSensors.count != 0 {
        for sensor in profileSensors {
          let thisSensor = sensor as! BBLSensor
          if uuid == thisSensor.uuid {
            thisSensor.sensorManager = self
            thisSensor.peripheral = peripheral
            thisSensor.onDidConnect()
            connectedSensors.insert(thisSensor)
            callDelegates{$0.sensorManager?(self, didConnectSensor: thisSensor)}
          }
        }
      }
      
    }
    
    
  }
  
  internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      for peripheral in peripheralsToDiscoverServices {
        peripheral.discoverServices([BBLSensorInfo.kSensorServiceUUID])
        peripheralsToDiscoverServices.remove(peripheral)
      }
      scanForSensors()
    } else if central.state == .poweredOff {
      for sensor in connectedSensors {
        sensor.disconnect()
      }
      connectedSensors.removeAll()
    } else {
      connectedSensors.removeAll()
    }
  }
  
  internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    
    for sensor in discoveredSensors {
      if sensor.peripheral == peripheral {discoveredSensors.remove(sensor)}
      callDelegates{$0.sensorManager!(self, didFailToConnectToSensor: sensor)
      }
    }
  }
  
}
