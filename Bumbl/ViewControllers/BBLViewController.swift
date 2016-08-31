//
//  BBLViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 8/30/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
  }
  
  
}
