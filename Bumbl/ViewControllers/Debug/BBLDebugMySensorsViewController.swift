//
//  BBLDebugMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLDebugMySensorsViewController: UIViewController {

// MARK: Constants
  
  private struct BBLDebugMySensorsViewControllerConstants {
    private static let kMySensorsTVCReuseIdentifier = "com.randy.myDebugSensorsTVCReuseIdentifier"
    private static let kMySensorsTVCNibName = "BBLDebugMySensorsTableViewCell"
    
    private static let noProfileSensorsMessage = "No sensors were found in your profile.  Please add a sensor to your profile by connecting to one."
    
    private struct FailedAddSensorAlert{
      private static let title = "Add Sensor to Profile Failed"
      private static let message = "Please make sure you have an active internet conection"
    }
    
    private struct FailedRemoveSensorAlert{
      private static let title = "Remove Sensor from Profile Failed"
      private static let message = "Please make sure you have an active internet conection"
    }
  }
  
// MARK: Interface Builder
  
  @IBOutlet weak var mySensorsTableView: UITableView!
  @IBOutlet weak var noProfileSensorsLabel: UILabel!
  @IBOutlet weak var tableViewBottomToSuperviewBottomConstraint: NSLayoutConstraint!
  
// MARK: Public Variables
  
  internal var loggedInParent:BBLParent!

// MARK: Private Variables
  
  private var mySensors: [BBLSensor]!
  
// MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableView(mySensorsTableView)
    setupEmptyTableViewCover(noProfileSensorsLabel)
    setupParent(loggedInParent)
    setupNotificationsForVC(self);
    setupGestureRecognizersForView(mySensorsTableView)
  }
  
// MARK: Setup
  
  private func setupParent(parent: BBLParent) {
    parent.delegate = self
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(BBLDebugMySensorsViewController.didTapLogout))
  }
  
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
    let cellNib = UINib(nibName: BBLDebugMySensorsViewControllerConstants.kMySensorsTVCNibName, bundle: NSBundle.mainBundle())
    tableView.registerNib(cellNib, forCellReuseIdentifier:BBLDebugMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier)
    tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    updateTableView()
  }
  
  private func updateTableView() {
    mySensors = loggedInParent.profileSensors.allObjects as? [BBLSensor]
    
    if mySensors.count == 0 ||
      mySensors == nil {
        noProfileSensorsLabel.hidden = false
    } else {
      noProfileSensorsLabel.hidden = true
    }
    
    mySensorsTableView.reloadData()
  }
  
  private func setupEmptyTableViewCover(view: UILabel) {
    view.backgroundColor = UIColor.BBLWetAsphaltColor()
    view.textColor = UIColor.BBLYellowColor()
    view.numberOfLines = 0
    view.text = BBLDebugMySensorsViewControllerConstants.noProfileSensorsMessage
  }
  
  private func setupNotificationsForVC(viewController: UIViewController) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLDebugMySensorsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BBLDebugMySensorsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  private func setupGestureRecognizersForView(view: UIView) {
    let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(BBLDebugMySensorsViewController.didTapTableView(_:)))
    view.addGestureRecognizer(tapGR)
  }
  
// MARK: Keyboard Actions
  internal func keyboardWillShow(notification:NSNotification!) {
    let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    tableViewBottomToSuperviewBottomConstraint.constant = keyboardFrame.height
  }
  
  internal func keyboardWillHide(notification:NSNotification!) {
    tableViewBottomToSuperviewBottomConstraint.constant = 0
  }
  
  internal func didTapTableView(tapGR: UITapGestureRecognizer!) {
    view.endEditing(true)
  }

// MARK: Navigation Bar
  
  internal func didTapLogout() {
    NSNotificationCenter.defaultCenter().postNotificationName(BBLNotifications.kParentDidLogoutNotification, object: self)
  }
  
// MARK: Alerts
  
  private func showDismissAlertWithTitle(title: String, withMessage message: String) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
}

// MARK: UITableViewDelegate

extension BBLDebugMySensorsViewController:UITableViewDelegate {
  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
}

// MARK: UITableViewDatasource

extension BBLDebugMySensorsViewController:UITableViewDataSource {
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let mySensors = mySensors else {
      return 0
    }
    return mySensors.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLDebugMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier, forIndexPath: indexPath) as! BBLDebugMySensorsTableViewCell
    
    cell.delegate = self
    cell.sensor = mySensors[indexPath.row]
    cell.sensor.delegate = self
    
    return cell
  }
}

// MARK: BBLDebugMySensorsTableViewCellDelegate

extension BBLDebugMySensorsViewController: BBLDebugMySensorsTableViewCellDelegate {
  internal func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didSaveThreshold threshold: Int, andName name: String?) {
    tableViewCell.sensor.capSenseThreshold = threshold
    tableViewCell.sensor.name = name
    tableViewCell.sensor.saveInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  internal func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool) {
    loggedInParent.removeSensor(tableViewCell.sensor)
    tableViewCell.sensor.disconnect()
  }
  
  internal func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didChangeThreshold threshold: Int) {
    tableViewCell.sensor.capSenseThreshold = threshold
  }
  
  internal func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didChangeDelayValue value: Int) {
    tableViewCell.sensor.delayInSeconds = value
    updateTableView()
  }
  
  internal func tableViewCell(tableViewCell: BBLDebugMySensorsTableViewCell, didTapRebaselineButton: Bool) {
    tableViewCell.sensor.rebaseline()
  }
}

// MARK: BBLParentDelegate

extension BBLDebugMySensorsViewController: BBLParentDelegate {
  internal func parent(parent: BBLParent, didAddSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func parent(parent: BBLParent, didFailAddSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLDebugMySensorsViewControllerConstants.FailedAddSensorAlert.title, withMessage: BBLDebugMySensorsViewControllerConstants.FailedAddSensorAlert.message + " " + errorMessage)
  }
  
  internal func parent(parent: BBLParent, didRemoveSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func parent(parent: BBLParent, didFailRemoveSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLDebugMySensorsViewControllerConstants.FailedRemoveSensorAlert.title, withMessage: BBLDebugMySensorsViewControllerConstants.FailedRemoveSensorAlert.message + " " + errorMessage)
  }
  
}

// MARK: BBLSensorDelegate

extension BBLDebugMySensorsViewController: BBLSensorDelegate {
  internal func sensor(sensor: BBLSensor, didUpdateSensorValue value: Int) {
    updateTableView()
  }
  
  internal func sensor(sensor: BBLSensor, didChangeState state: BBLSensorState) {
    updateTableView()
  }
  
  internal func sensor(sensor: BBLSensor, didDidFailToDeleteSensorWithErrorMessage errorMessage: String) {
    //TODO: Handle displaying this error.
  }
  
  internal func sensor(sensor: BBLSensor, didUpdateRSSI rssi: NSNumber) {
    updateTableView()
  }

}