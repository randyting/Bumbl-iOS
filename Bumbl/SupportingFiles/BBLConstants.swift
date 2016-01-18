//
//  BBLConstants.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

/// BLE service UUID that all sensors advertise.  The characteristics we use must be under this service.
let kSensorServiceUUID = CBUUID.init(string: "DCD68980-AADC-11E1-A22A-0002A5D5C51B")

/// BLE characteristic UUID for cap sense measurement.
let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "2A5A")

/// Cap sense threshold for determining if baby is on sensor or not.
let kDefaultCapSenseThreshold = 50