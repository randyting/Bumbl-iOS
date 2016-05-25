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
  
  @IBAction func didTapNextButton(sender: AnyObject) {
    
    let signInPickerVC = BBLSignInPickerVC()
    signInPickerVC.userDefaults = NSUserDefaults.standardUserDefaults()
    navigationController?.pushViewController(signInPickerVC, animated: true)
    
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    nextButton.tintColor = UIColor.BBLNavyBlueColor()
  }
  
}
