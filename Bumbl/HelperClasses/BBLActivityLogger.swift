//
//  BBLActivityLogger.swift
//  Bumbl
//
//  Created by Randy Ting on 8/6/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import Firebase

class BBLActivityLogger: NSObject {
  
  // MARK: Singleton
  
  internal static let sharedInstance = BBLActivityLogger()
  
  // MARK: Private Variables
  
  private var rootDatabase: FIRDatabase
  private var rootRef: FIRDatabaseReference
  
  // MARK: Initialization
  
  override init() {
    FIRApp.configure()
    rootDatabase = FIRDatabase.database()
    rootRef = rootDatabase.reference()
  }
  
  // MARK: Sensor Value Logging
  
  internal func logSensorValue(value: UInt, forSensor sensor: BBLSensor) {
    
    guard let uuid = sensor.uuid else {
      fatalError("Cannot log sensor value because sensor UUID does not exist")
    }
    
    let logRef = rootRef.child(uuid).childByAutoId()
    let log = ["sensorValue" : value]
    logRef.updateChildValues(log)
    
    
    let timestampRef = logRef.child("timestamp")
    let timestamp = FIRServerValue.timestamp()
    timestampRef.setValue(timestamp)
  }
  

}
