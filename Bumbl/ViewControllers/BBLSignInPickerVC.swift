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
  internal var userDefaults: UserDefaults?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  @IBAction func didTapLoginButton(_ sender: AnyObject) {
    
    let loginVC = BBLLoginViewController()
    loginVC.delegate = UIApplication.shared.delegate as! BBLAppDelegate
    loginVC.presentationDelegate = self
    
    navigationController?.pushViewController(loginVC, animated: true)
    
  }
  
  @IBAction func didTapRegisterButton(_ sender: UIButton) {
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    markOnboardingCompleteInDefaults(userDefaults)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
  }
  
  // MARK: Initial Setup
  
  fileprivate func setupAppearance() {
    
    view.backgroundColor = UIColor.white
    
    setupAppearanceForButton(loginButton)
    setupAppearanceForButton(registerButton)
    
  }
  
  fileprivate func setupAppearanceForButton(_ button: UIButton) {
    
    button.tintColor = UIColor.BBLNavyBlueColor()
    button.backgroundColor = UIColor.white
    button.addTopBorder(withColor: UIColor.BBLNavyBlueColor(), withThickness: 0.5)
    
  }
  
  fileprivate func markOnboardingCompleteInDefaults(_ defaults: UserDefaults?) {
    defaults?.set(true, forKey: BBLAppState.kDefaultsOnboardingCompleteKey)
  }
  
}

extension BBLSignInPickerVC:BBLLoginViewControllerPresentationDelegate {
  
  internal func logInViewControllerDidCancelLogIn(_ logInController: BBLLoginViewController) {
    dismiss(animated: true, completion: nil)
  }
  
}
