//
//  NSData+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 8/7/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension Data {
  
  public func BBLswapUInt16Data() -> Data? {
    
    // Copy data into UInt16 array:
    let count = self.count / MemoryLayout<UInt16>.size
    var array = [UInt16](repeating: 0, count: count)
    (self as NSData).getBytes(&array, length: count * MemoryLayout<UInt16>.size)
    
    // Swap each integer:
    for i in 0 ..< count {
      array[i] = array[i].byteSwapped // *** (see below)
    }
    
    // Create NSData from array:
    
    return Data(bytes: UnsafePointer<UInt8>(OpaquePointer(array)), count: count * MemoryLayout<UInt16>.size)
//    return Data(bytes: UnsafePointer<UInt8>(&array), count: count * sizeof(UInt16))
  }
  
}
