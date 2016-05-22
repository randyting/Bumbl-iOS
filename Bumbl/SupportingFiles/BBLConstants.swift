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
  struct BBLDebugMySensorsViewController {
    static let title = "My Sensors"
    static let tabBarIcon:UIImage? = nil
  }
  
  struct BBLDebugConnectionViewController {
    static let title = "Connect"
    static let tabBarIcon:UIImage? = nil
  }
}

// MARK: App State
internal struct BBLAppState {
  
  /// Key in NSUserdefaults for determining whether onboarding flow should be presented.
  static let kDefaultsOnboardingCompleteKey = "com.bumbl.kDefaultsOnboardingCompletKey"
  
}

// MARK: Sensor Info
internal struct BBLSensorInfo {
  
  /// BLE service UUID that all sensors advertise.  The characteristics we use must be under this service.
  static let kSensorServiceUUID = CBUUID.init(string: "0003CAB5-0000-1000-8000-00805F9B0131")
  
  /// BLE characteristic UUID for cap sense measurement.
  static let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "0003CAA1-0000-1000-8000-00805F9B0131")
  
  /// Value to write to rebaseline characteristic to rebaseline
  static let kRebaselineValue = "rebaseline".dataUsingEncoding(NSUTF8StringEncoding)
  
  /// Cap sense threshold for determining if baby is on sensor or not.
  static let kDefaultCapSenseThreshold = 50
  
  /// Default delay for transition between activated and deactivated states
  static let kDefaultDelayInSeconds = 3
  
  /// Default delay for checking if another parent is connected.
  static let kDefaultCheckOtherParentConnectDelayInSeconds = 120.0
  
  /// Alerts that will be triggered when the app is backgrounded.
  struct Alerts {
    // When the baby is in the carseat and the sensor disconnects, but another parent does not connect to the sensor.
    static let babyInSeatAndOutOfRangeAlertTitle = "Get your baby!"
    static let babyInSeatAndOutOfRangeAlertMessage = " is still in your car!"
    
    // When the baby is in the carseat and the sensor disconnects, but another parent connects to the sensor.
    static let babyInSeatWithOtherParentAlertTitle = "Don't worry."
    static let babyInSeatWithOtherParentAlertMessage = " is safe with another caretaker."
    
    // When the sensor disconnects without a baby.
    static let sensorActivatedAlertTitle = "Baby placed in seat."
    static let sensorActivatedAlertMessage = "'s Sensor Activated."
    
    // When the sensor connects.
    static let sensorDeactivatedAlertTitle = "Baby removed from seat"
    static let sensorDeactivatedAlertMessage = "'s Sensor Deactivated."
    
  }
}

// MARK:  Notifications
internal struct BBLNotifications {  
  /// On parent logout
  static let kParentDidLogoutNotification = "com.randy.ParentDidLogoutNotification"
}


