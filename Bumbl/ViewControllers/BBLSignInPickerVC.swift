//
//  BBLSignInPickerVC.swift
//  Bumbl
//
//  Created by Randy Ting on 3/5/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLSignInPickerVC: UIViewController {
  
  // MARK: Public Variables
  internal var userDefaults: NSUserDefaults?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBAction func didTapLoginButton(sender: AnyObject) {
    
    let loginVC = BBLLoginViewController()
    loginVC.delegate = UIApplication.sharedApplication().delegate as! BBLAppDelegate
    
    presentViewController(loginVC, animated: true, completion: nil)
    
  }
  
  @IBAction func didTapRegisterButton(sender: UIButton) {
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    markOnboardingCompleteInDefaults(userDefaults)
    
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.BBLYellowColor()
    
    setupAppearanceForButton(loginButton)
    setupAppearanceForButton(registerButton)
    
  }
  
  private func setupAppearanceForButton(button: UIButton) {
    
    button.tintColor = UIColor.BBLDarkGreyTextColor()
    button.backgroundColor = UIColor.BBLYellowColor()
    button.layer.shadowColor = UIColor.blackColor().CGColor
    button.layer.shadowOpacity = 0.8
    button.layer.shadowRadius = 12
    button.layer.shadowOffset = CGSize(width: 0, height: -1.0)
  }
  
  private func markOnboardingCompleteInDefaults(defaults: NSUserDefaults?) {
    defaults?.setBool(true, forKey: BBLAppState.kDefaultsOnboardingCompleteKey)
  }
  
  
}
