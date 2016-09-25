//
//  BBLParseAPIClient.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

internal final class BBLParseAPIClient: NSObject {
  
  class func queryForBabySensorsConnectedToParent(_ parent: BBLParent, withCompletion completion: @escaping ([BBLSensor]?) -> Void) {
    let query = PFQuery(className: "BabySensor")
    query.whereKey("connectedParent", equalTo: parent)
    query.findObjectsInBackground {(sensors:[PFObject]?, error:Error?) -> Void in
      
      if let error = error {
        print(error.localizedDescription)
        return
      } else if let sensors = sensors as? [BBLSensor]{
        completion(sensors)
      }
    }
  }
  
  class func queryForExistingBabySensorsWithUUID(_ uuid: String, withCompletion completion:@escaping ([BBLSensor]?) -> Void) {
    let query = PFQuery(className: "BabySensor")
    query.whereKey("uuid", equalTo: uuid)
    query.findObjectsInBackground {(sensors:[PFObject]?, error:Error?) -> Void in
      
      if let error = error {
        print(error.localizedDescription)
        return
      } else if let sensors = sensors as? [BBLSensor]{
        completion(sensors)
      }
    }
  }
  
}
