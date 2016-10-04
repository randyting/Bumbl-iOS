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
  
  internal enum Event: String {
    case Activated = "Activated"
    case Deactivated = "Deactivated"
    case Connected = "Connected"
    case Disconnected = "Disconnected"
  }
  
  // MARK: Singleton
  
  internal static let sharedInstance = BBLActivityLogger()
  
  // MARK: Private Variables
  
  fileprivate var rootDatabase: FIRDatabase
  fileprivate var rootRef: FIRDatabaseReference
  
  // MARK: Initialization
  
  override init() {
    FIRApp.configure()
    rootDatabase = FIRDatabase.database()
    rootRef = rootDatabase.reference()
  }
  
  // MARK: Sensor Value Logging
  
  internal func logSensorValue(_ value: UInt, forSensor sensor: BBLSensor, forEvent event: Event) {
    
    guard let uuid = sensor.uuid else {
      fatalError("Cannot log sensor value because sensor UUID does not exist")
    }
    
    let logRef = rootRef.child(uuid).childByAutoId()
    let log = ["sensorValue" : value]
    logRef.updateChildValues(log)
    
    
    let timestampRef = logRef.child("timestamp")
    let timestamp = FIRServerValue.timestamp()
    timestampRef.setValue(timestamp)
    
    let eventRef = logRef.child("event")
    eventRef.setValue(event.rawValue)
  }
  

}
