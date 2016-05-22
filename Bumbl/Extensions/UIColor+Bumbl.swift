//
//  UIColor+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIColor {
  
  internal class func BBLGrayColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#E8E8E8")
  }
  
  internal class func BBLDarkGrayColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#787878")
  }
  
  internal class func BBLYellowColor() -> UIColor {
    return UIColor(colorLiteralRed: 0.90, green: 0.92, blue: 0.35, alpha: 1.0);
  }
  
  internal class func BBLWetAsphaltColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#34495e")
  }
  
  internal class func BBLDarkGreyTextColor() -> UIColor {
    return UIColor(colorLiteralRed: 0.27, green: 0.28, blue: 0.32, alpha: 1.0);
  }
  
  internal class func BBLPinkColor() -> UIColor {
    return UIColor.BBLColorfromHexString("EE4987")
  }
  
  internal class func BBLNavyBlueColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#145282")
  }
  
  internal class func BBLBlueColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#1977B9")
  }
  
  internal class func BBLTealGreenColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#39BEB2")
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