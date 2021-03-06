//
//  UIView+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIView {
  
  public func addTopBorder(withColor color: UIColor, withThickness thickness: CGFloat) {
    
    let topBorder = CALayer.init();
    topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: thickness)
    topBorder.backgroundColor = color.cgColor
    self.layer.addSublayer(topBorder)
    
  }
  
  public func makeHorizontalOval(withBorderThickness borderThickness: CGFloat, withBorderColor borderColor: UIColor?){
    
    self.clipsToBounds = true
    self.layer.cornerRadius = self.frame.height/2
    self.layer.borderColor = borderColor?.cgColor
    self.layer.borderWidth = borderThickness
    
  }
  
  // Note: shadow cannot be added if clipsToBounds or layer.masksToBounds is set to false.
  public func addShadow(withColor color: UIColor,
                    withOpacity opacity: Float,
                      withRadius radius: CGFloat,
                  withOffsetWidth width: CGFloat,
                withOffsetHeight height: CGFloat) {
    
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOpacity = opacity
    self.layer.shadowRadius = radius
    self.layer.shadowOffset = CGSize(width: width, height: height)
    
  }
  
}
