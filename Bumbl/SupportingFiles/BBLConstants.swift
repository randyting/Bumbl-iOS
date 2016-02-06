//
//  BBLConstants.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation
import CoreBluetooth


// MARK: View Controllers
internal struct BBLViewControllerInfo {
  struct BBLMySensorsViewController {
    static let title = "My Sensors"
    static let tabBarIcon:UIImage? = nil
  }
  
  struct BBLConnectionViewController {
    static let title = "Connect"
    static let tabBarIcon:UIImage? = nil
  }
}

// MARK: Sensor Info
internal struct BBLSensorInfo {
  /// BLE service UUID that all sensors advertise.  The characteristics we use must be under this service.
  static let kSensorServiceUUID = CBUUID.init(string: "0003CAB5-0000-1000-8000-00805F9B0131")
  
  /// BLE characteristic UUID for cap sense measurement.
  static let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "0003CAA1-0000-1000-8000-00805F9B0131")
  
  /// Cap sense threshold for determining if baby is on sensor or not.
  static let kDefaultCapSenseThreshold = 50
  
  /// Alerts that will be triggered when the app is backgrounded.
  struct Alerts {
    // When the baby is in the carseat and the sensor disconnects.
    static let babyInSeatAndOutOfRangeAlertTitle = "Your baby is still in your car!"
    static let babyInSeatAndOutOfRangeAlertMessage = "Get your baby!"
    
    // When the sensor disconnects without a baby.
    static let sensorActivatedAlertTitle = "Baby placed in seat."
    static let sensorActivatedAlertMessage = "Sensor Activated."
    
    // When the sensor connects.
    static let sensorDeactivatedAlertTitle = "Baby removed from seat"
    static let sensorDeactivatedAlertMessage = "Sensor Deactivated."
    
  }
}

// MARK:  Notifications
internal struct BBLNotifications {  
  /// On parent logout
  static let kParentDidLogoutNotification = "com.randy.ParentDidLogoutNotification"
}

