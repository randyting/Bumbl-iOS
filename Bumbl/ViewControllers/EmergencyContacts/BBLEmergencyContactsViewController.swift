//
//  BBLEmergencyContactsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLEmergencyContactsViewController: BBLViewController {
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationItem(navigationItem)
  }
  
  // MARK: Setup
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    
    BBLsetupHamburgerMenuForNavItem(navItem)
  }
  
}
