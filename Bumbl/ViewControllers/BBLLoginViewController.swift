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
}

internal protocol BBLLoginViewControllerPresentationDelegate: class {
  
  func logInViewControllerDidCancelLogIn(logInController: BBLLoginViewController)
  
}

class BBLLoginViewController: UIViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLLoginViewControllerDelegate?
  internal weak var presentationDelegate: BBLLoginViewControllerPresentationDelegate?
  
  // MARK: Interface Builder
  
  
  @IBOutlet weak var titleButton: UIButton!
  @IBOutlet weak var passwordLabel: UILabel!
  
  @IBOutlet weak var emailLabel: UILabel!
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginWithFacebookButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!
  
  @IBAction func didTapLoginButton(sender: UIButton) {
    
    // TODO: Guard against bad input
    
    dismissKeyboard()
    
    let username = emailTextField.text
    let password = passwordTextField.text
    
    if (delegate?.logInViewController(self, shouldBeginLogInWithUsername: username!, password: password!) == false) {
      return
    }
    
    PFUser.logInWithUsernameInBackground(username!, password: password!) { (user: PFUser?, error: NSError?) -> Void in
      
      if let error = error {
        self.showLoginFailedAlertWithError(error)
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
  
  @IBAction func didTapTitleButton(sender: UIButton) {
    presentationDelegate?.logInViewControllerDidCancelLogIn(self);
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.BBLYellowColor()
    
    setupAppearanceForTitleButton(titleButton)
    
    setupAppearanceForTextField(emailTextField)
    setupAppearanceForTextField(passwordTextField)
    
    setupAppearanceForFederatedLoginButton(loginWithFacebookButton)
    
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
  
  private func setupAppearanceForTitleButton(button: UIButton) {
    button.tintColor = UIColor.BBLDarkGreyTextColor()
  }
  
  private func setupAppearanceForTextField(textfield: UITextField) {
    
    insetTextInTextfield(textfield, byWidth: 15)
    textfield.clipsToBounds = true
    textfield.layer.cornerRadius = textfield.frame.height/2
    textfield.layer.borderColor = UIColor.grayColor().CGColor
    textfield.layer.borderWidth = 1.0
  }
  
  private func insetTextInTextfield(textfield: UITextField, byWidth width: Int) {
    
    let spacerView = UIView(frame:CGRect(x:0, y:0, width:width, height:10))
    textfield.leftViewMode = UITextFieldViewMode.Always
    textfield.leftView = spacerView
    textfield.rightViewMode = UITextFieldViewMode.Always
    textfield.rightView = spacerView
    
  }
  
  private func setupAppearanceForFederatedLoginButton(button: UIButton) {
    button.tintColor = UIColor.BBLDarkGreyTextColor()
    button.backgroundColor = UIColor.BBLGrayColor()
    button.clipsToBounds = true
    button.layer.cornerRadius = 5.0
  }
  
  private func setupNotificationsForVC(viewController: UIViewController) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  private func setupGestureRecognizersForView(view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLLoginViewController.didTapView(_:)))
    view.addGestureRecognizer(tapGR)
  }
  
  // MARK: Keyboard Actions
  internal func keyboardWillShow(notification:NSNotification!) {
    let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    // TODO: Change size of scrollview.
  }
  
  internal func keyboardWillHide(notification:NSNotification!) {
    // TODO: Change size of scrollview.
  }
  
  internal func didTapView(tapGR: UITapGestureRecognizer!) {
    dismissKeyboard()
  }
  
  private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: Login Error Alert
  
  private func showLoginFailedAlertWithError(error: NSError?) {
    
    let alertController = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }


  
}
