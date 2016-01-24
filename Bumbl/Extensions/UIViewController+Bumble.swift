//
//  UIViewController+Bumble.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIViewController {
  internal func BBLsetupIcon(icon: UIImage?, andTitle title: String?) {
    navigationController?.tabBarItem.title = title
    navigationController?.tabBarItem.image = icon
    
    tabBarItem.title = title
    tabBarItem.image = icon
    
    self.title = title
  }
}
