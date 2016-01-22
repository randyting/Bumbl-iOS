//
//  BBLParent.swift
//  Bumbl
//
//  Created by Randy Ting on 1/19/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLParent: PFUser {
  
  @NSManaged internal var sensors:[BBLSensor]?
  private(set) var profileSensors:NSMutableSet!

// MARK: Synchronization
  internal func syncSensors(){
    profileSensors = NSMutableSet()
    if let sensors = sensors {
      for sensor in sensors {
        profileSensors.addObject(sensor)
      }
    }
  }
  
// MARK: Sensor Management
  internal func addSensor(sensor: BBLSensor) {
    profileSensors!.addObject(sensor)
    sensors = profileSensors!.allObjects as? [BBLSensor]
    saveInBackground()
  }
  
  internal func removeSensor(sensor: BBLSensor) {
    guard profileSensors!.containsObject(sensor) else {
      return
    }
    
    profileSensors!.removeObject(sensor)
    sensors = profileSensors!.allObjects as? [BBLSensor]
    saveInBackground()
  }
  
// MARK: Class Methods
  class func loggedInParent() -> BBLParent {
    return PFUser.currentUser() as! BBLParent
  }
  
}
