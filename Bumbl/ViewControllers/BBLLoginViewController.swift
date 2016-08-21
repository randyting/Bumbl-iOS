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
  
  // MARK: Constants
  
  private struct BBLLoginViewControllerConstants {
  
    private static let kTitle = "Account Login"
    
    private static let kEmailTextFieldTitle = "Email"
    private static let kEmailTextFieldPlaceholder = "user@bumblbaby.com"
    
    private static let kPasswordTextFieldTitle = "Password"
    private static let kPassworTextFieldPlaceholder = "password"
  
  }
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLLoginViewControllerDelegate?
  internal weak var presentationDelegate: BBLLoginViewControllerPresentationDelegate?
  
  // MARK: Interface Builder
  

  @IBOutlet weak var emailTextField: BBLTextField!
  @IBOutlet weak var passwordTextField: BBLTextField!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginWithFacebookButton: UIButton!
  
  @IBAction func didTapLoginButton(sender: UIButton) {
    
    // TODO: Guard against bad input
    
    dismissKeyboard()
    
    let username = emailTextField.text
    let password = passwordTextField.text
    
    if (delegate?.logInViewController(self, shouldBeginLogInWithUsername: username, password: password) == false) {
      return
    }
    
    PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
      
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
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    setupTextFields()
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
  }
  
  override func willMoveToParentViewController(parent: UIViewController?) {
    guard let _ = parent else {
      presentationDelegate?.logInViewControllerDidCancelLogIn(self)
      return
    }
    

  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    
    view.backgroundColor = UIColor.whiteColor()
    navigationController?.navigationBarHidden = false
    title = BBLLoginViewControllerConstants.kTitle
    
    setupAppearanceForFederatedLoginButton(loginWithFacebookButton)
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
    
  }
  
  private func setupTextFields() {
    emailTextField.title = BBLLoginViewControllerConstants.kEmailTextFieldTitle
    emailTextField.placeholder = BBLLoginViewControllerConstants.kEmailTextFieldPlaceholder
    
    passwordTextField.title = BBLLoginViewControllerConstants.kPasswordTextFieldTitle
    passwordTextField.placeholder = BBLLoginViewControllerConstants.kPassworTextFieldPlaceholder
  }
  
  private func setupAppearanceForFederatedLoginButton(button: UIButton) {
    
    button.tintColor = UIColor.whiteColor()
    button.backgroundColor = UIColor.BBLBlueColor()
    
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
