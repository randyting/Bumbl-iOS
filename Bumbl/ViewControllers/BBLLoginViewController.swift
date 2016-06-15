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
  
  @IBOutlet weak var divisionLine: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var passwordLabel: UILabel!
  
  @IBOutlet weak var emailLabel: UILabel!
  
  @IBOutlet weak var emailTextField: BBLTextField!
  @IBOutlet weak var passwordTextField: BBLTextField!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginWithFacebookButton: UIButton!
  
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
  
  @IBAction func didTapBackButton(sender: UIButton) {
    
    presentationDelegate?.logInViewControllerDidCancelLogIn(self);
    
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.whiteColor()
    
    setupAppearanceForTitle(titleLabel)
    
    setupAppearanceForSecondaryTextField(emailTextField)
    setupAppearanceForPrimaryTextField(passwordTextField)
    
    setupAppearanceForDivisionLine(divisionLine)
    
    setupAppearanceForFederatedLoginButton(loginWithFacebookButton)
    
    setupAppearanceForCircleButton(loginButton)
    
  }
  
  private func setupAppearanceForCircleButton(button: UIButton) {
    
    button.backgroundColor = UIColor.clearColor()
    
  }
  
  private func setupAppearanceForTitle(label: UILabel) {
    label.tintColor = UIColor.BBLDarkGreyTextColor()
  }
  
  private func setupAppearanceForSecondaryTextField(textfield: UITextField) {
    // TODO: Add drop shadow.
    textfield.backgroundColor = UIColor.BBLGrayColor()
  }
  
  private func setupAppearanceForPrimaryTextField(textfield: UITextField) {
    textfield.backgroundColor = UIColor.BBLTealGreenColor()
  }
  
  private func setupAppearanceForDivisionLine(view: UIView) {
    view.backgroundColor = UIColor.BBLDarkGrayColor()
  }
  
  private func setupAppearanceForFederatedLoginButton(button: UIButton) {
    
    button.tintColor = UIColor.whiteColor()
    button.backgroundColor = UIColor.BBLBlueColor()
    button.makeHorizontalOval(withBorderThickness: 0.0, withBorderColor: nil)
    // TODO: Add drop shadow.
    
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
    (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
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
