//
//  BBLAddContactViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 8/30/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLAddContactViewControllerDelegate: class {
  func BBLAddContactVC(_ addContactViewController: BBLAddContactViewController, didTapDoneButton doneButton: BBLModalBottomButton)
}

class BBLAddContactViewController: BBLViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLAddContactViewControllerDelegate?
  
  // MARK: Constants
  
  struct BBLAddContactViewControllerConstants {
    
    fileprivate static let kTitle = "Add Contact"
    
    fileprivate static let kFirstNameTextFieldTitle = "First"
    fileprivate static let kFirstNameTextFieldPlaceholder = "First Name"
    
    fileprivate static let kLastNameTextFieldTitle = "Last"
    fileprivate static let kLastNameTextFieldPlaceholder = "Last Name"
    
    fileprivate static let kPhoneNumberTextFieldTitle = "Phone"
    fileprivate static let kPhoneNumberTextFieldPlaceholder = "(XXX) XXX-XXXXX"
    
    fileprivate static let kEmailTextFieldTitle = "Email"
    fileprivate static let kEmailTextFieldPlaceholder = "contact@bumblebaby.com"
    
  }
  
  // MARK: Interface Builder
  
  @IBOutlet weak var firstNameTextField: BBLTextField!
  @IBOutlet weak var lastNameTextField: BBLTextField!
  @IBOutlet weak var phoneNumberTextField: BBLTextField!
  @IBOutlet weak var emailTextField: BBLTextField!
  
  @IBOutlet weak var topStackViewToContainerTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var importContactButton: BBLModalBottomButton!
  
  @IBAction func didTapImportContactButton(_ sender: AnyObject) {
    // TODO: Implement Contacts Kit
  }
  
  @IBAction func didTapDoneButton(_ sender: BBLModalBottomButton) {
    
    let newContact = BBLContact(withFirstName: firstNameTextField.text,
                                withLastName: lastNameTextField.text,
                                withPhoneNumber: phoneNumberTextField.text,
                                withEmail: emailTextField.text,
                                withParent: BBLParent.loggedInParent()!)
    newContact.saveInBackground { (success: Bool, error: Error?) in
      if let error = error {
        self.showSaveFailedAlertWithError(error)
      } else {
        self.delegate?.BBLAddContactVC(self, didTapDoneButton: sender)
      }
    }
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = BBLAddContactViewControllerConstants.kTitle
    tabBarController?.tabBar.isHidden = true
    
    setupTopPositionConstraint(topStackViewToContainerTopConstraint)
    setupAppearanceForImportContactButton(importContactButton)
    setupTextFields()
  }
  
  override func willMove(toParentViewController parent: UIViewController?) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: Setup
  
  fileprivate func setupTopPositionConstraint(_ constraint: NSLayoutConstraint) {
    let originalConstant = constraint.constant
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 35 + originalConstant
    }
  }
  
  fileprivate func setupAppearanceForImportContactButton(_ button: UIButton) {
    button.tintColor = UIColor.white
    button.backgroundColor = UIColor.BBLBlueColor()
  }
  
  fileprivate func setupTextFields() {
    firstNameTextField.title = BBLAddContactViewControllerConstants.kFirstNameTextFieldTitle
    firstNameTextField.placeholder = BBLAddContactViewControllerConstants.kFirstNameTextFieldPlaceholder
    firstNameTextField.isTextField = true
    
    lastNameTextField.title = BBLAddContactViewControllerConstants.kLastNameTextFieldTitle
    lastNameTextField.placeholder = BBLAddContactViewControllerConstants.kLastNameTextFieldPlaceholder
    lastNameTextField.isTextField = true
    
    phoneNumberTextField.title = BBLAddContactViewControllerConstants.kPhoneNumberTextFieldTitle
    phoneNumberTextField.placeholder = BBLAddContactViewControllerConstants.kPhoneNumberTextFieldPlaceholder
    phoneNumberTextField.isTextField = true
    
    emailTextField.title = BBLAddContactViewControllerConstants.kEmailTextFieldTitle
    emailTextField.placeholder = BBLAddContactViewControllerConstants.kEmailTextFieldPlaceholder
    emailTextField.isTextField = true
  }
  
  // MARK: Save Error Alert
  
  fileprivate func showSaveFailedAlertWithError(_ error: Error?) {
    
    let alertController = UIAlertController(title: "Save Contact Error", message: error?.localizedDescription, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }
}
