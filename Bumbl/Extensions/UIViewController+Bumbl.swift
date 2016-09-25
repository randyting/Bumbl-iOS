//
//  UIViewController+Bumbl.swift
//  Bumbl
//
//  Created by Randy Ting on 1/23/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation

extension UIViewController {
  
  internal func BBLsetupIcon(_ icon: UIImage?, andTitle title: String?) {
    navigationController?.tabBarItem.title = title
    navigationController?.tabBarItem.image = icon
    
    tabBarItem.title = title
    tabBarItem.image = icon
    
    self.title = title
  }
  
  internal func BBLsetupHamburgerMenuForNavItem(_ navItem: UINavigationItem) {
    
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kMenuButtonIconName),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.BBLdidTapHamburgerMenuButton(_:)))
    
  }
  
  @objc internal func BBLdidTapHamburgerMenuButton(_ sender: UIBarButtonItem) {
    
    let menuVC = BBLMenuViewController()
    menuVC.delegate = self
    let navController = UINavigationController(rootViewController: menuVC)
    
    present(navController, animated: true, completion: nil)
  }

  internal func BBLsetupBlueNavigationBar(_ navBar: UINavigationBar?) {
    navBar?.barTintColor = UIColor.BBLLightBlueNavBarColor()
    navBar?.tintColor = UIColor.white
    navBar?.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.white]
  }
  
  internal func BBLsetupWhiteNavigationBar(_ navBar: UINavigationBar?) {
    navBar?.barTintColor = UIColor.white
    navBar?.tintColor = UIColor.black
    navBar?.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.black]
  }
  
}

extension UIViewController: BBLMenuViewControllerDelegate {
  
  internal func BBLmenuViewController(_ menuViewController: BBLMenuViewController, didDismiss: Bool){
    dismiss(animated: true, completion: nil)
  }
  
}
