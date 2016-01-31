//
//  BBLParent.swift
//  Bumbl
//
//  Created by Randy Ting on 1/19/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLParentDelegate: class {
  optional func parent(parent: BBLParent, didAddSensor sensor: BBLSensor)
  optional func parent(parent: BBLParent, didFailAddSensor sensor: BBLSensor, withErrorMessage errorMessage: String)
  optional func parent(parent: BBLParent, didRemoveSensor sensor: BBLSensor)
  optional func parent(parent: BBLParent, didFailRemoveSensor sensor: BBLSensor, withErrorMessage errorMessage: String)
}

internal final class BBLParent: PFUser {

// MARK: Public Variables
  
  @NSManaged internal var sensors:[BBLSensor]?
  private(set) var profileSensors:NSMutableSet!
  internal weak var delegate: BBLParentDelegate?

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
    saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      if let error = error {
        self.delegate?.parent?(self, didFailAddSensor: sensor, withErrorMessage: error.localizedDescription)
      } else {
        self.delegate?.parent?(self, didAddSensor: sensor)
      }
    }
  }
  
  internal func removeSensor(sensor: BBLSensor) {
    guard profileSensors!.containsObject(sensor) else {
      return
    }
    sensor.decrementParentsCount()
    profileSensors!.removeObject(sensor)
    sensors = profileSensors!.allObjects as? [BBLSensor]
    saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      if let error = error {
        self.delegate?.parent?(self, didFailRemoveSensor: sensor, withErrorMessage: error.localizedDescription)
      } else {
        self.delegate?.parent?(self, didRemoveSensor: sensor)
      }
    }
  }
  
// MARK: Class Methods
  class func loggedInParent() -> BBLParent? {
    return PFUser.currentUser() as? BBLParent
  }
}
