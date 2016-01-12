//
//  BBLSensor.swift
//  Bumbl
//
//  Created by Randy Ting on 1/12/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLSensor: NSObject {
  
// MARK: Public variables
  private(set) var hasBaby:Bool? {
    get {
      if let _ = strainGaugeValue {
        return strainGaugeValue > strainGaugeThreshold
      } else {
        return false // If no strain gauge value read
      }
    }
    set {
      self.hasBaby = newValue
    }
  }
  
  private let bean:PTDBean?
  private var strainGaugeValue:UInt16?
  private var strainGaugeThreshold:UInt16!
  
  
// MARK: Initialization
  
  // Initializer for instantating an existing bean loaded from the server or persistent storage.
  init(withBean bean: PTDBean?, fromJSONDictionary dictionary: NSDictionary) {
    self.bean = bean
    super.init()
  }
  
  // Initializer for instantiating a new bean that is not registered to a parent, but detected by bluetooth radio.
  init(withBean bean: PTDBean!, withStrainGaugeThreshold threshold: UInt16) {
    self.bean = bean
    self.strainGaugeThreshold = threshold
    super.init()
    
    bean.delegate = self
  }
  
}

// MARK: PTDBean Delegate

extension BBLSensor:PTDBeanDelegate {
  
  internal func beanDidUpdateRSSI(bean: PTDBean!, error: NSError!) {
    // TODO: (RT) Display to user how close bean is to phone.
  }
  
  internal func bean(bean: PTDBean!, didUpdateScratchBank bank: Int, data: NSData!) {
    var adcValue:UInt16 = 0;
    data.getBytes(&adcValue, length: sizeof(UInt16))
    strainGaugeValue = max(600 - adcValue, 0)
  }
}

