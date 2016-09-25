//
//  BBLLoginViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

internal protocol BBLLoginViewControllerDelegate: class {
  
  func logInViewController(_ logInController: BBLLoginViewController, didFailToLogInWithError error: Error?)
  func logInViewController(_ logInController: BBLLoginViewController, didLogInUser user: PFUser)
  func logInViewController(_ logInController: BBLLoginViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool
}

internal protocol BBLLoginViewControllerPresentationDelegate: class {
  
  func logInViewControllerDidCancelLogIn(_ logInController: BBLLoginViewController)
  
}

class BBLLoginViewController: UIViewController {
  
  // MARK: Constants
  
  fileprivate struct BBLLoginViewControllerConstants {
  
    fileprivate static let kTitle = "Account Login"
    
    fileprivate static let kEmailTextFieldTitle = "Email"
    fileprivate static let kEmailTextFieldPlaceholder = "user@bumblbaby.com"
    
    fileprivate static let kPasswordTextFieldTitle = "Password"
    fileprivate static let kPasswordTextFieldPlaceholder = "password"
  
  }
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLLoginViewControllerDelegate?
  internal weak var presentationDelegate: BBLLoginViewControllerPresentationDelegate?
  
  // MARK: Interface Builder
  

  @IBOutlet weak var emailTextField: BBLTextField!
  @IBOutlet weak var passwordTextField: BBLTextField!
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginWithFacebookButton: UIButton!
  
  @IBAction func didTapLoginButton(_ sender: UIButton) {
    
    // TODO: Guard against bad input
    
    dismissKeyboard()
    
    let username = emailTextField.text
    let password = passwordTextField.text
    
    if (delegate?.logInViewController(self, shouldBeginLogInWithUsername: username, password: password) == false) {
      return
    }
    
    PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) -> Void in
      
      if let error = error {
        self.showLoginFailedAlertWithError(error)
        self.delegate?.logInViewController(self, didFailToLogInWithError: error)
      } else {
        self.delegate?.logInViewController(self, didLogInUser: user!)
      }
    }
    
  }
  
  @IBAction func didTapLoginWithFacebookButton(_ sender: UIButton) {
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
    setupTextFields()
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
  }
  
  override func willMove(toParentViewController parent: UIViewController?) {
    guard let _ = parent else {
      presentationDelegate?.logInViewControllerDidCancelLogIn(self)
      return
    }
    

  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  
  // MARK: Initial Setup
  
  fileprivate func setupAppearance() {
    
    view.backgroundColor = UIColor.white
    navigationController?.isNavigationBarHidden = false
    title = BBLLoginViewControllerConstants.kTitle
    
    setupAppearanceForFederatedLoginButton(loginWithFacebookButton)
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
    
  }
  
  fileprivate func setupTextFields() {
    emailTextField.title = BBLLoginViewControllerConstants.kEmailTextFieldTitle
    emailTextField.placeholder = BBLLoginViewControllerConstants.kEmailTextFieldPlaceholder
    
    passwordTextField.title = BBLLoginViewControllerConstants.kPasswordTextFieldTitle
    passwordTextField.placeholder = BBLLoginViewControllerConstants.kPasswordTextFieldPlaceholder
  }
  
  fileprivate func setupAppearanceForFederatedLoginButton(_ button: UIButton) {
    
    button.tintColor = UIColor.white
    button.backgroundColor = UIColor.BBLBlueColor()
    
  }
  
  fileprivate func setupNotificationsForVC(_ viewController: UIViewController) {
    NotificationCenter.default.addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  fileprivate func setupGestureRecognizersForView(_ view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLLoginViewController.didTapView(_:)))
    view.addGestureRecognizer(tapGR)
  }
  
  // MARK: Keyboard Actions
  internal func keyboardWillShow(_ notification:Notification!) {
    (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    // TODO: Change size of scrollview.
  }
  
  internal func keyboardWillHide(_ notification:Notification!) {
    // TODO: Change size of scrollview.
  }
  
  internal func didTapView(_ tapGR: UITapGestureRecognizer!) {
    dismissKeyboard()
  }
  
  fileprivate func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: Login Error Alert
  
  fileprivate func showLoginFailedAlertWithError(_ error: Error?) {
    
    let alertController = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }


  
}
