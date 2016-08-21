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
    loginVC.presentationDelegate = self
    
    navigationController?.pushViewController(loginVC, animated: true)
    
  }
  
  @IBAction func didTapRegisterButton(sender: UIButton) {
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    markOnboardingCompleteInDefaults(userDefaults)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = true
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.whiteColor()
    
    setupAppearanceForButton(loginButton)
    setupAppearanceForButton(registerButton)
    
  }
  
  private func setupAppearanceForButton(button: UIButton) {
    
    button.tintColor = UIColor.BBLNavyBlueColor()
    button.backgroundColor = UIColor.whiteColor()
    button.addTopBorder(withColor: UIColor.BBLNavyBlueColor(), withThickness: 0.5)
    
  }
  
  private func markOnboardingCompleteInDefaults(defaults: NSUserDefaults?) {
    defaults?.setBool(true, forKey: BBLAppState.kDefaultsOnboardingCompleteKey)
  }
  
}

extension BBLSignInPickerVC:BBLLoginViewControllerPresentationDelegate {
  
  internal func logInViewControllerDidCancelLogIn(logInController: BBLLoginViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}