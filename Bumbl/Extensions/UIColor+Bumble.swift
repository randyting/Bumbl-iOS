//
//  UIColor+Bumble.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIColor {
  
  internal class func BBLGrayColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#95a5a6")
  }
  
  internal class func BBLYellowColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#f1c40f")
  }
  
  private class func BBLColorfromHexString(hexString: String) -> UIColor {
    var rgbValue: UInt32 = 0
    let scanner = NSScanner(string: hexString)
    scanner.scanLocation = 1
    scanner.scanHexInt(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue >> 16) & 0xff) / 255,
      green: CGFloat((rgbValue >> 08) & 0xff) / 255,
      blue: CGFloat((rgbValue >> 00) & 0xff) / 255,
      alpha: 1.0)
  }
  
}