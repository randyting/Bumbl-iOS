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
  
  fileprivate func startScanWithSensorManager(_ sensorManager: BBLSensorManager) {
    sensorManager.registerDelegate(self)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        () -> Void in
        // Must wait for sensorManager to be in powered on state before scanning
        sensorManager.scanForSensors()
    }
  }
  
}

extension BBLSession: BBLSensorManagerDelegate {
  
  func sensorManager(_ sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    print("Did connect to sensor " + sensor.description)
    if parent.profileSensors.contains(sensor){
      parent.addSensor(sensor)
    } else {
      sensor.incrementParentsCount()
      parent.addSensor(sensor)
    }
    
  }
  
  func sensorManager(_ sensorManager: BBLSensorManager, didAttemptToScanWhileBluetoothRadioIsOff isBluetoothRadioOff: Bool) {
    print("Did attempt to scan while BT radio is off.")
  }
  
  func sensorManager(_ sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    print("Did disconnect sensor " + sensor.description)
  }
  
  func sensorManager(_ sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor) {
    print("Did discover sensor " + sensor.description)
  }
}
