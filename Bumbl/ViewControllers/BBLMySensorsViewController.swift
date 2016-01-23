//
//  BBLMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLMySensorsViewController: UIViewController {
  
  internal var loggedInParent:BBLParent!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "My Sensors"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "didTapLogout")
    navigationController?.tabBarItem.title = "Connected Sensors"
    tabBarItem.title = "Connected Sensors"
  }
  
  internal func didTapLogout() {
    NSNotificationCenter.defaultCenter().postNotificationName(BBLNotifications.kParentDidLogoutNotification, object: self)
  }
  
}
