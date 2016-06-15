//
//  BBLEditSensorViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLEditSensorViewControllerDelegate: class {
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton)
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapCancelButton bottomButton: UIBarButtonItem)
}

class BBLEditSensorViewController: UIViewController {
  
  struct BBLEditSensorViewControllerConstants {
    
    private static let kAvatarCVCReuseIdentifier = "com.randy.avatarCVCReuseIdentifier"
    private static let kTitle = "EDIT SENSOR"
    
  }
  
  // MARK: Public Variables
  
  internal var sensor: BBLSensor!
  internal weak var delegate: BBLEditSensorViewControllerDelegate?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var avatarTitleLabelTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var avatarCollectionView: UICollectionView!
  @IBOutlet weak var babyNameTextField: BBLTextField!
  @IBOutlet weak var productSerialNumberTextField: BBLTextField!
  @IBOutlet weak var bottomButton: BBLModalBottomButton!
  
  @IBAction func didTapBottomButton(sender: BBLModalBottomButton) {
    
    sensor.name = babyNameTextField.text
    
    sensor.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
      if let error = error {
        self.showSaveFailedAlertWithError(error)
      } else {
        self.delegate?.BBLEditSensorVC(self, didTapBottomButton: sender)
      }
    }
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    title = BBLEditSensorViewControllerConstants.kTitle
    
    setupCollectionView(avatarCollectionView)
    setupAppearanceForTextField(babyNameTextField)
    setupAppearanceForTextField(productSerialNumberTextField)
    BBLsetupWhiteNavigationBar(navigationController?.navigationBar)
    setupTopPositionConstraint(avatarTitleLabelTopConstraint)
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
    setupModalDismissButtonForNavItem(navigationItem)
    
    updateAllFields()
  }
  
  // MARK: Setup
  
  private func setupCollectionView(collectionView: UICollectionView) {
    collectionView.registerClass(UICollectionViewCell.self,
                                 forCellWithReuseIdentifier: BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier)
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  private func setupAppearanceForTextField(textField: UITextField) {
    textField.backgroundColor = UIColor.BBLTealGreenColor()
  }
  
  private func setupTopPositionConstraint(constraint: NSLayoutConstraint) {
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 40
    }
  }
  
  private func setupNotificationsForVC(viewController: UIViewController) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  private func setupGestureRecognizersForView(view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLLoginViewController.didTapView(_:)))
    view.addGestureRecognizer(tapGR)
  }
  
  private func setupModalDismissButtonForNavItem(navItem: UINavigationItem) {
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kDismissButtonIconName),
                                                 style: .Plain,
                                                 target: self,
                                                 action: #selector(BBLMenuViewController.didTapDismissButton(_:)))
  }
  
  internal func didTapDismissButton(sender: UIBarButtonItem) {
    delegate?.BBLEditSensorVC(self, didTapCancelButton: sender)
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
  
  // MARK: Update
  
  private func updateAllFields() {
    productSerialNumberTextField.text = sensor.uuid
    babyNameTextField.text = sensor.name
  }
  
  // MARK: Save Error Alert
  
  private func showSaveFailedAlertWithError(error: NSError?) {
    
    let alertController = UIAlertController(title: "Save Sensor Error", message: error?.localizedDescription, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
}


extension BBLEditSensorViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //
  }
  
}

extension BBLEditSensorViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return BBLAvatarsInfo.BBLAvatarType.Count.rawValue
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier, forIndexPath: indexPath)
    
    cell.backgroundColor = UIColor.blackColor()
    
    return cell
  }
  
  
}