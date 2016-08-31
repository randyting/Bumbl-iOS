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
}

class BBLEditSensorViewController: UIViewController {
  
  struct BBLEditSensorViewControllerConstants {
    
    private static let kAvatarCVCReuseIdentifier = "com.randy.avatarCVCReuseIdentifier"
    private static let kTitle = "Device Info"
    
    private static let kDeviceNoListingTitle = "Device No."
    
    private static let kBabyNameTextFieldTitle = "Baby Name"
    private static let kBabyNameTextFieldPlaceholder = "Enter Baby Name"
    
  }
  
  // MARK: Public Variables
  
  internal var sensor: BBLSensor!
  internal weak var delegate: BBLEditSensorViewControllerDelegate?
  
  // MARK: Private Variables
  
  private var selectedAvatar: BBLAvatarsInfo.BBLAvatarType?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var avatarTitleLabelTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var avatarCollectionView: UICollectionView!
  @IBOutlet weak var babyNameTextField: BBLTextField!
  @IBOutlet weak var productSerialNumberTextField: BBLTextField!
  @IBOutlet weak var bottomButton: BBLModalBottomButton!
  @IBOutlet weak var deleteButton: BBLModalBottomButton!
  
  @IBOutlet var bottomTextFieldToBottomConstraint: NSLayoutConstraint!
  @IBOutlet var productSerialNumberLabelTopToAvatarCollectionViewConstraint: NSLayoutConstraint!
  
  @IBAction func didTapDeleteButton(sender: BBLModalBottomButton) {
    BBLParent.loggedInParent()?.removeSensor(sensor)
    sensor.disconnect()
  }
  
  @IBAction func didTapBottomButton(sender: BBLModalBottomButton) {
    
    sensor.name = babyNameTextField.text
    
    if let selectedAvatar = selectedAvatar {
      sensor.avatar = selectedAvatar.rawValue
    }
    
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
    selectedAvatar = BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)
    tabBarController?.tabBar.hidden = true
    
    setupTextFields()
    setupCollectionView(avatarCollectionView)
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
    setupTopPositionConstraint(avatarTitleLabelTopConstraint)
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
    setupAppearanceForDeleteButton(deleteButton)
    
    updateAllFields()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func willMoveToParentViewController(parent: UIViewController?) {
    tabBarController?.tabBar.hidden = false
  }
  
  // MARK: Setup
  
  private func setupTextFields() {
    productSerialNumberTextField.title = BBLEditSensorViewControllerConstants.kDeviceNoListingTitle
    productSerialNumberTextField.isTextField = false
    
    babyNameTextField.title = BBLEditSensorViewControllerConstants.kBabyNameTextFieldTitle
    babyNameTextField.placeholder = BBLEditSensorViewControllerConstants.kBabyNameTextFieldPlaceholder
  }
  
  private func setupCollectionView(collectionView: UICollectionView) {
    collectionView.registerClass(UICollectionViewCell.self,
                                 forCellWithReuseIdentifier: BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.clearColor()
    collectionView.allowsSelection = true
    collectionView.allowsMultipleSelection = false
  }
  
  private func setupTopPositionConstraint(constraint: NSLayoutConstraint) {
    bottomTextFieldToBottomConstraint.active = false
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 35
    }
  }
  
  private func setupNotificationsForVC(viewController: UIViewController) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  private func setupGestureRecognizersForView(view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLLoginViewController.didTapView(_:)))
    tapGR.delegate = self
    view.addGestureRecognizer(tapGR)
  }
  
  private func setupAppearanceForDeleteButton(button: UIButton) {
    button.backgroundColor = UIColor.redColor()
    button.tintColor = UIColor.whiteColor()
  }
  
  // MARK: Keyboard Actions
  internal func keyboardWillShow(notification:NSNotification!) {
    let keyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
    let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
    let options = UIViewAnimationOptions(rawValue: UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
    productSerialNumberLabelTopToAvatarCollectionViewConstraint.active = false
    
    
    UIView.animateWithDuration(animationDuration, delay: 0.0, options:options, animations: {
      self.bottomTextFieldToBottomConstraint.active = true
      self.bottomTextFieldToBottomConstraint.constant = keyboardHeight
      }, completion: nil)
    
    
  }
  
  internal func keyboardWillHide(notification:NSNotification!) {
    productSerialNumberLabelTopToAvatarCollectionViewConstraint.active = true
    bottomTextFieldToBottomConstraint.active = false
  }
  
  internal func didTapView(tapGR: UITapGestureRecognizer!) {
    dismissKeyboard()
  }
  
  private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: Update
  
  private func updateAllFields() {
    productSerialNumberTextField.text = sensor.uuid!
    babyNameTextField.text = sensor.name!
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
    
    if let selectedAvatar = selectedAvatar,
      let rhs = BBLAvatarsInfo.BBLAvatarType(rawValue:indexPath.row)
      where selectedAvatar.isEqual(rhs) {
      
      unhighlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
      return
      
    } else if let selectedAvatar = selectedAvatar,
      let rhs = BBLAvatarsInfo.BBLAvatarType(rawValue:indexPath.row)
      where !selectedAvatar.isEqual(rhs){
      
      let lastIndexPath = NSIndexPath(forRow: selectedAvatar.rawValue, inSection: 0)
      unhighlightAvatarAtIndexPath(lastIndexPath, inCollectionView: collectionView)
      highlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
      return
    }
    
    highlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
    
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    
    selectedAvatar = nil
    collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.clearColor()
    
  }
  
  private func unhighlightAvatarAtIndexPath(indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    collectionView.delegate?.collectionView!(collectionView, didDeselectItemAtIndexPath: indexPath)
  }
  
  private func highlightAvatarAtIndexPath(indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) {
    selectedAvatar = BBLAvatarsInfo.BBLAvatarType(rawValue: indexPath.row)
    collectionView.cellForItemAtIndexPath(indexPath)?.contentView.backgroundColor = UIColor.blackColor()
  }
  
}

extension BBLEditSensorViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return BBLAvatarsInfo.BBLAvatarType.Count.rawValue
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier, forIndexPath: indexPath)
    cell.userInteractionEnabled = true
    
    cell.backgroundView = UIImageView(image: BBLAvatarsInfo.BBLAvatarType(rawValue: indexPath.row)?.image())
    
    cell.contentView.layer.cornerRadius = cell.contentView.frame.height/2.0
    cell.contentView.alpha = 0.3
    
    if BBLAvatarsInfo.BBLAvatarType(rawValue: indexPath.row) == selectedAvatar {
      cell.contentView.backgroundColor = UIColor.blackColor()
    }
    
    return cell
  }
  
}

extension BBLEditSensorViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    
    if let touchView = touch.view where touchView.isDescendantOfView(avatarCollectionView) {
      return false
    } else {
      return true
    }
    
  }
  
}