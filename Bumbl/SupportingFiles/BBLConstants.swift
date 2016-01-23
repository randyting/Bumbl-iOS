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
  }
  
  struct BBLConnectionViewController {
    static let title = "Connect"
  }
}

// MARK: Sensor Info
internal struct BBLSensorInfo {
  /// BLE service UUID that all sensors advertise.  The characteristics we use must be under this service.
  static let kSensorServiceUUID = CBUUID.init(string: "DCD68980-AADC-11E1-A22A-0002A5D5C51B")
  
  /// BLE characteristic UUID for cap sense measurement.
  static let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "2A5A")
  
  /// Cap sense threshold for determining if baby is on sensor or not.
  static let kDefaultCapSenseThreshold = 50
}

// MARK:  Notifications
internal struct BBLNotifications {  
  /// On parent logout
  static let kParentDidLogoutNotification = "com.randy.ParentDidLogoutNotification"
}

