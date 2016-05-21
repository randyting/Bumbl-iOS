//
//  UIView+Bumble.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIView {
  
  public func addTopBorder(withColor color: UIColor, withThickness thickness: CGFloat) {
    
    let topBorder = CALayer.init();
    topBorder.frame = CGRectMake(0.0, 0.0, self.frame.size.width, thickness)
    topBorder.backgroundColor = color.CGColor
    self.layer.addSublayer(topBorder)
    
  }
  
}