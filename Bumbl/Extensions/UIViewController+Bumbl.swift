//
//  UIViewController+Bumbl.swift
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
  
  internal func setupHamburgerMenuForNavItem(navItem: UINavigationItem) {
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kMenuButtonIconName),
                                                 style: .Plain,
                                                 target: self,
                                                 action: #selector(self.didTapHamburgerMenuButton(_:)))
  }
  
  internal func setupBlueNavigationBar(navBar: UINavigationBar?) {
    navBar?.barTintColor = UIColor.BBLLightBlueNavBarColor()
    navBar?.tintColor = UIColor.whiteColor()
    navBar?.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor()]
  }
  
  @objc internal func didTapHamburgerMenuButton(sender: UIBarButtonItem) {
    
  }
  
  
  
}
