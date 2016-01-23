//
//  BBLSession.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

internal final class BBLSession: NSObject {
  internal var parent: BBLParent!
  internal var sensorManager: BBLSensorManager!
  
  internal init(withParent parent: BBLParent!,
    withSensorManager sensorManager: BBLSensorManager!) {
      self.parent = parent
      self.sensorManager = sensorManager
      super.init()
      
      self.startScanWithSensorManager(sensorManager)
  }
  
  private func startScanWithSensorManager(sensorManager: BBLSensorManager) {
    sensorManager.registerDelegate(self)
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
      Int64(0.5 * Double(NSEC_PER_SEC))),
      dispatch_get_main_queue()) {
        () -> Void in
        // Must wait for sensorManager to be in powered on state before scanning
        sensorManager.scanForSensors()
    }
  }
  
}

extension BBLSession: BBLSensorManagerDelegate {
  
  func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    print("Did connect to sensor " + sensor.description)
    parent.addSensor(sensor)
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didAttemptToScanWhileBluetoothRadioIsOff isBluetoothRadioOff: Bool) {
    print("Did attempt to scan while BT radio is off.")
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    print("Did disconnect sensor " + sensor.description)
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor) {
    print("Did discover sensor " + sensor.description)
//    sensor.connect()
  }
}