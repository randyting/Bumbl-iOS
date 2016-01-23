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
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "didTapLogout")

  }
  
  internal func didTapLogout() {
    NSNotificationCenter.defaultCenter().postNotificationName(BBLNotifications.kParentDidLogoutNotification, object: self)
  }
  
}
