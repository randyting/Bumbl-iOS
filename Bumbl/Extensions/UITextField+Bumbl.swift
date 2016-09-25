//
//  UITextField+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UITextField {
  
  public func insetText(byWidth width: Int){
    
    let spacerView = UIView(frame:CGRect(x:0, y:0, width:width, height:10))
    self.leftViewMode = UITextFieldViewMode.always
    self.leftView = spacerView
    self.rightViewMode = UITextFieldViewMode.always
    self.rightView = spacerView
    
  }
  
  
}
