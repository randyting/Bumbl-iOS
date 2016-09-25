//
//  BBLAddSensorViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLAddSensorViewController: BBLEditSensorViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    deleteButton.isHidden = true
    navigationItem.rightBarButtonItems?.removeAll()
    navigationItem.hidesBackButton = true
    title = "Add Sensor"
    
  }
  
}
