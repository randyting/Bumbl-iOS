//
//  BBLLoginViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

internal protocol BBLLoginViewControllerDelegate: class {
  
  func logInViewController(logInController: BBLLoginViewController, didFailToLogInWithError error: NSError?)
  func logInViewController(logInController: BBLLoginViewController, didLogInUser user: PFUser)
  func logInViewController(logInController: BBLLoginViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool
  func logInViewControllerDidCancelLogIn(logInController: BBLLoginViewController)
}

class BBLLoginViewController: UIViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLLoginViewControllerDelegate?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var passwordLabel: UILabel!
  
  @IBOutlet weak var emailLabel: UILabel!
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginWithFacebookButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!
  
  @IBAction func didTapLoginButton(sender: UIButton) {
    
    // TODO: Guard against bad input
    
    let username = emailTextField.text
    let password = passwordTextField.text
    
    if (delegate?.logInViewController(self, shouldBeginLogInWithUsername: username!, password: password!) == false) {
      return
    }
    

    PFUser.logInWithUsernameInBackground(username!, password: password!) { (user: PFUser?, error: NSError?) -> Void in
      
      if let error = error {
        self.delegate?.logInViewController(self, didFailToLogInWithError: error)
      } else {
        self.delegate?.logInViewController(self, didLogInUser: user!)
      }
    }
    
    
  }
  
  @IBAction func didTapLoginWithFacebookButton(sender: UIButton) {
  }
  
  @IBAction func didTapRegisterButton(sender: UIButton) {
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.BBLYellowColor()
    
    setupAppearanceForCircleButton(loginButton)
    setupAppearanceForBottomButton(registerButton)
    
  }
  
  private func setupAppearanceForCircleButton(button: UIButton) {
    
    button.clipsToBounds = true
    button.layer.cornerRadius = button.frame.height/2
    button.backgroundColor = UIColor.BBLPinkColor()
    
  }
  
  private func setupAppearanceForBottomButton(button: UIButton) {
    
    button.tintColor = UIColor.BBLDarkGreyTextColor()
    button.backgroundColor = UIColor.BBLYellowColor()
    button.layer.shadowColor = UIColor.blackColor().CGColor
    button.layer.shadowOpacity = 0.8
    button.layer.shadowRadius = 12
    button.layer.shadowOffset = CGSize(width: 0, height: -1.0)
  }
  
}
