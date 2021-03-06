//
//  UIColor+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIColor {
  
  internal class func BBLGrayTextColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#909090")
  }
  
  internal class func BBLGrayColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#E8E8E8")
  }
  
  internal class func BBLActivatedDotGreenColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#33E38A")
  }
  
  internal class func BBLActivatedDotRedColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#F71042")
  }
  
  internal class func BBLActivatedDotGrayColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#868686")
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
  
  internal class func BBLDarkBlueColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#185181")
  }
  
  internal class func BBLLightBlueNavBarColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#70E6E0")
  }
  
  internal class func BBLBlueColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#1977B9")
  }
  
  internal class func BBLTealGreenColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#39BEB2")
  }
  
  internal class func BBLBrightTealGreenColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#3FBEB2")
  }
  
  internal class func BBLAvatarGreenColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#BBD7A8")
  }
  
  internal class func BBLAvatarYellowColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#FDEE5B")
  }
  
  internal class func BBLAvatarPurpleColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#868AC3")
  }
  
  internal class func BBLAvatarPinkColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#F39DC1")
  }
  
  internal class func BBLAvatarBlueColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#D5E7ED")
  }
  
  internal class func BBLAvatarOrangeColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#FAAF3F")
  }
  
  internal class func BBLTabBarSelectedIconColor() -> UIColor {
    return UIColor.BBLColorfromHexString("#6189AD")
  }
  
  
  fileprivate class func BBLColorfromHexString(_ hexString: String) -> UIColor {
    var rgbValue: UInt32 = 0
    let scanner = Scanner(string: hexString)
    scanner.scanLocation = 1
    scanner.scanHexInt32(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue >> 16) & 0xff) / 255,
      green: CGFloat((rgbValue >> 08) & 0xff) / 255,
      blue: CGFloat((rgbValue >> 00) & 0xff) / 255,
      alpha: 1.0)
  }
  
}
