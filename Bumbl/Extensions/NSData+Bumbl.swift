//
//  NSData+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 8/7/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension NSData {
  
  public func BBLswapUInt16Data() -> NSData? {
    
    // Copy data into UInt16 array:
    let count = self.length / sizeof(UInt16)
    var array = [UInt16](count: count, repeatedValue: 0)
    self.getBytes(&array, length: count * sizeof(UInt16))
    
    // Swap each integer:
    for i in 0 ..< count {
      array[i] = array[i].byteSwapped // *** (see below)
    }
    
    // Create NSData from array:
    return NSData(bytes: &array, length: count * sizeof(UInt16))
  }
  
}
