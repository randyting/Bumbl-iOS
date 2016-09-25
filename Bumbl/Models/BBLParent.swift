//
//  BBLParent.swift
//  Bumbl
//
//  Created by Randy Ting on 1/19/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLParentDelegate: class {
  @objc optional func parent(_ parent: BBLParent, didAddSensor sensor: BBLSensor)
  @objc optional func parent(_ parent: BBLParent, didFailAddSensor sensor: BBLSensor, withErrorMessage errorMessage: String)
  @objc optional func parent(_ parent: BBLParent, didRemoveSensor sensor: BBLSensor)
  @objc optional func parent(_ parent: BBLParent, didFailRemoveSensor sensor: BBLSensor, withErrorMessage errorMessage: String)
}

internal final class BBLParent: PFUser {

// MARK: Public Variables
  
  @NSManaged internal var sensors:[BBLSensor]?
  fileprivate(set) var profileSensors:NSMutableSet!
  internal weak var delegate: BBLParentDelegate?

// MARK: Synchronization
  
  internal func syncSensors(){
    profileSensors = NSMutableSet()
    if let sensors = sensors {
      for sensor in sensors {
        profileSensors.add(sensor)
      }
    }
  }
  
// MARK: Sensor Management
  
  internal func addSensor(_ sensor: BBLSensor) {
    profileSensors!.add(sensor)
    sensors = profileSensors!.allObjects as? [BBLSensor]
    saveInBackground { (success: Bool, error: Error?) -> Void in
      if let error = error {
        self.delegate?.parent?(self, didFailAddSensor: sensor, withErrorMessage: error.localizedDescription)
      } else {
        self.delegate?.parent?(self, didAddSensor: sensor)
      }
    }
  }
  
  internal func removeSensor(_ sensor: BBLSensor) {
    guard profileSensors!.contains(sensor) else {
      return
    }
    sensor.decrementParentsCount()
    profileSensors!.remove(sensor)
    sensors = profileSensors!.allObjects as? [BBLSensor]
    saveInBackground { (success: Bool, error: Error?) -> Void in
      if let error = error {
        self.delegate?.parent?(self, didFailRemoveSensor: sensor, withErrorMessage: error.localizedDescription)
      } else {
        self.delegate?.parent?(self, didRemoveSensor: sensor)
        sensor.disconnect()
      }
    }
  }
  
// MARK: Class Methods
  class func loggedInParent() -> BBLParent? {
    return PFUser.current() as? BBLParent
  }
}
