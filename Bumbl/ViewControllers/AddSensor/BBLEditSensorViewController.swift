//
//  BBLEditSensorViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLEditSensorViewControllerDelegate: class {
  func BBLEditSensorVC(_ vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton)
}

class BBLEditSensorViewController: BBLViewController {
  
  struct BBLEditSensorViewControllerConstants {
    
    fileprivate static let kAvatarCVCReuseIdentifier = "com.randy.avatarCVCReuseIdentifier"
    fileprivate static let kTitle = "Device Info"
    
    fileprivate static let kDeviceNoListingTitle = "Device No."
    
    fileprivate static let kBabyNameTextFieldTitle = "Baby Name"
    fileprivate static let kBabyNameTextFieldPlaceholder = "Enter Baby Name"
    
  }
  
  // MARK: Public Variables
  
  internal var sensor: BBLSensor!
  internal weak var delegate: BBLEditSensorViewControllerDelegate?
  
  // MARK: Private Variables
  
  fileprivate var selectedAvatar: BBLAvatarsInfo.BBLAvatarType?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var avatarTitleLabelTopConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var avatarCollectionView: UICollectionView!
  @IBOutlet weak var babyNameTextField: BBLTextField!
  @IBOutlet weak var productSerialNumberTextField: BBLTextField!
  @IBOutlet weak var bottomButton: BBLModalBottomButton!
  @IBOutlet weak var deleteButton: BBLModalBottomButton!
  
  @IBOutlet var bottomTextFieldToBottomConstraint: NSLayoutConstraint!
  @IBOutlet var productSerialNumberLabelTopToAvatarCollectionViewConstraint: NSLayoutConstraint!
  
  @IBAction func didTapDeleteButton(_ sender: BBLModalBottomButton) {
    BBLParent.loggedInParent()?.removeSensor(sensor)
  }
  
  @IBAction func didTapBottomButton(_ sender: BBLModalBottomButton) {
    
    sensor.name = babyNameTextField.text
    
    if let selectedAvatar = selectedAvatar {
      sensor.avatar = selectedAvatar.rawValue
    }
    
    sensor.saveInBackground { (success: Bool, error: Error?) in
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
    tabBarController?.tabBar.isHidden = true
    
    setupTextFields()
    setupCollectionView(avatarCollectionView)
    setupTopPositionConstraint(avatarTitleLabelTopConstraint)
    setupNotificationsForVC(self)
    setupGestureRecognizersForView(view)
    setupAppearanceForDeleteButton(deleteButton)
    
    updateAllFields()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func willMove(toParentViewController parent: UIViewController?) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: Setup
  
  fileprivate func setupTextFields() {
    productSerialNumberTextField.title = BBLEditSensorViewControllerConstants.kDeviceNoListingTitle
    productSerialNumberTextField.isTextField = false
    
    babyNameTextField.title = BBLEditSensorViewControllerConstants.kBabyNameTextFieldTitle
    babyNameTextField.placeholder = BBLEditSensorViewControllerConstants.kBabyNameTextFieldPlaceholder
  }
  
  fileprivate func setupCollectionView(_ collectionView: UICollectionView) {
    collectionView.register(UICollectionViewCell.self,
                                 forCellWithReuseIdentifier: BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.clear
    collectionView.allowsSelection = true
    collectionView.allowsMultipleSelection = false
  }
  
  fileprivate func setupTopPositionConstraint(_ constraint: NSLayoutConstraint) {
    bottomTextFieldToBottomConstraint.isActive = false
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 35
    }
  }
  
  fileprivate func setupNotificationsForVC(_ viewController: UIViewController) {
    NotificationCenter.default.addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(BBLLoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  fileprivate func setupGestureRecognizersForView(_ view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLLoginViewController.didTapView(_:)))
    tapGR.delegate = self
    view.addGestureRecognizer(tapGR)
  }
  
  fileprivate func setupAppearanceForDeleteButton(_ button: UIButton) {
    button.backgroundColor = UIColor.red
    button.tintColor = UIColor.white
  }
  
  // MARK: Keyboard Actions
  internal func keyboardWillShow(_ notification:Notification!) {
    let keyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
    let options = UIViewAnimationOptions(rawValue: UInt((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
    productSerialNumberLabelTopToAvatarCollectionViewConstraint.isActive = false
    
    
    UIView.animate(withDuration: animationDuration, delay: 0.0, options:options, animations: {
      self.bottomTextFieldToBottomConstraint.isActive = true
      self.bottomTextFieldToBottomConstraint.constant = keyboardHeight
      }, completion: nil)
    
    
  }
  
  internal func keyboardWillHide(_ notification:Notification!) {
    productSerialNumberLabelTopToAvatarCollectionViewConstraint.isActive = true
    bottomTextFieldToBottomConstraint.isActive = false
  }
  
  internal func didTapView(_ tapGR: UITapGestureRecognizer!) {
    dismissKeyboard()
  }
  
  fileprivate func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: Update
  
  fileprivate func updateAllFields() {
    productSerialNumberTextField.text = sensor.uuid!
    babyNameTextField.text = sensor.name!
  }
  
  // MARK: Save Error Alert
  
  fileprivate func showSaveFailedAlertWithError(_ error: Error?) {
    
    let alertController = UIAlertController(title: "Save Sensor Error", message: error?.localizedDescription, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
}


extension BBLEditSensorViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if let selectedAvatar = selectedAvatar,
      let rhs = BBLAvatarsInfo.BBLAvatarType(rawValue:(indexPath as NSIndexPath).row)
      , selectedAvatar.isEqual(rhs) {
      
      unhighlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
      return
      
    } else if let selectedAvatar = selectedAvatar,
      let rhs = BBLAvatarsInfo.BBLAvatarType(rawValue:(indexPath as NSIndexPath).row)
      , !selectedAvatar.isEqual(rhs){
      
      let lastIndexPath = IndexPath(row: selectedAvatar.rawValue, section: 0)
      unhighlightAvatarAtIndexPath(lastIndexPath, inCollectionView: collectionView)
      highlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
      return
    }
    
    highlightAvatarAtIndexPath(indexPath, inCollectionView: collectionView)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    selectedAvatar = nil
    collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor.clear
    
  }
  
  fileprivate func unhighlightAvatarAtIndexPath(_ indexPath: IndexPath, inCollectionView collectionView: UICollectionView) {
    collectionView.deselectItem(at: indexPath, animated: true)
    collectionView.delegate?.collectionView!(collectionView, didDeselectItemAt: indexPath)
  }
  
  fileprivate func highlightAvatarAtIndexPath(_ indexPath: IndexPath, inCollectionView collectionView: UICollectionView) {
    selectedAvatar = BBLAvatarsInfo.BBLAvatarType(rawValue: (indexPath as NSIndexPath).row)
    collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor.black
  }
  
}

extension BBLEditSensorViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return BBLAvatarsInfo.BBLAvatarType.count.rawValue
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BBLEditSensorViewControllerConstants.kAvatarCVCReuseIdentifier, for: indexPath)
    cell.isUserInteractionEnabled = true
    
    cell.backgroundView = UIImageView(image: BBLAvatarsInfo.BBLAvatarType(rawValue: (indexPath as NSIndexPath).row)?.image())
    
    cell.contentView.layer.cornerRadius = cell.contentView.frame.height/2.0
    cell.contentView.alpha = 0.3
    
    if BBLAvatarsInfo.BBLAvatarType(rawValue: (indexPath as NSIndexPath).row) == selectedAvatar {
      cell.contentView.backgroundColor = UIColor.black
    }
    
    return cell
  }
  
}

extension BBLEditSensorViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
    if let touchView = touch.view , touchView.isDescendant(of: avatarCollectionView) {
      return false
    } else {
      return true
    }
    
  }
  
}
