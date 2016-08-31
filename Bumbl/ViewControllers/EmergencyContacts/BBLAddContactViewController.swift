//
//  BBLAddContactViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 8/30/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLAddContactViewControllerDelegate: class {
  func BBLAddContactVC(addContactViewController: BBLAddContactViewController, didTapDoneButton doneButton: BBLModalBottomButton)
}

class BBLAddContactViewController: BBLViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLAddContactViewControllerDelegate?
  
  // MARK: Constants
  
  struct BBLAddContactViewControllerConstants {
    
    private static let kTitle = "Add Contact"
    
    private static let kFirstNameTextFieldTitle = "First"
    private static let kFirstNameTextFieldPlaceholder = "First Name"
    
    private static let kLastNameTextFieldTitle = "Last"
    private static let kLastNameTextFieldPlaceholder = "Last Name"
    
    private static let kPhoneNumberTextFieldTitle = "Phone"
    private static let kPhoneNumberTextFieldPlaceholder = "(XXX) XXX-XXXXX"
    
    private static let kEmailTextFieldTitle = "Email"
    private static let kEmailTextFieldPlaceholder = "contact@bumblebaby.com"
    
  }
  
  // MARK: Interface Builder
  
  @IBOutlet weak var firstNameTextField: BBLTextField!
  @IBOutlet weak var lastNameTextField: BBLTextField!
  @IBOutlet weak var phoneNumberTextField: BBLTextField!
  @IBOutlet weak var emailTextField: BBLTextField!
  
  @IBOutlet weak var topStackViewToContainerTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var importContactButton: BBLModalBottomButton!
  
  @IBAction func didTapImportContactButton(sender: AnyObject) {
    // TODO: Implement Contacts Kit
  }
  
  @IBAction func didTapDoneButton(sender: BBLModalBottomButton) {
    
    let newContact = BBLContact(withFirstName: firstNameTextField.text,
                                withLastName: lastNameTextField.text,
                                withPhoneNumber: phoneNumberTextField.text,
                                withEmail: emailTextField.text,
                                withParent: BBLParent.loggedInParent()!)
    newContact.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
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
    tabBarController?.tabBar.hidden = true
    
    setupTopPositionConstraint(topStackViewToContainerTopConstraint)
    setupAppearanceForImportContactButton(importContactButton)
    setupTextFields()
  }
  
  override func willMoveToParentViewController(parent: UIViewController?) {
    tabBarController?.tabBar.hidden = false
  }
  
  // MARK: Setup
  
  private func setupTopPositionConstraint(constraint: NSLayoutConstraint) {
    let originalConstant = constraint.constant
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 35 + originalConstant
    }
  }
  
  private func setupAppearanceForImportContactButton(button: UIButton) {
    button.tintColor = UIColor.whiteColor()
    button.backgroundColor = UIColor.BBLBlueColor()
  }
  
  private func setupTextFields() {
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
  
  private func showSaveFailedAlertWithError(error: NSError?) {
    
    let alertController = UIAlertController(title: "Save Contact Error", message: error?.localizedDescription, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}
