//
//  BBLRemoveBatteryTabViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 3/5/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLRemoveBatteryTabViewController: UIViewController {
  
  // MARK: Interface Builder
  
  @IBOutlet weak var nextButton: UIButton!
  
  @IBAction func didTapNextButton(_ sender: AnyObject) {
    
    let signInPickerVC = BBLSignInPickerVC()
    signInPickerVC.userDefaults = UserDefaults.standard
    navigationController?.pushViewController(signInPickerVC, animated: true)
    
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
  }
  
  // MARK: Initial Setup
  
  fileprivate func setupAppearance() {
    nextButton.tintColor = UIColor.BBLNavyBlueColor()
  }
  
}
