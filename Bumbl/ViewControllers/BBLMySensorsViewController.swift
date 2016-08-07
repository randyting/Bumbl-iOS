//
//  BBLMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLMySensorsViewController: UIViewController {
  
  // MARK: Constants
  
  private struct BBLMySensorsViewControllerConstants {
    
    private static let kMySensorsTVCReuseIdentifier = "com.randy.mySensorsTVCReuseIdentifier"
    private static let kMySensorsTVCNibName = "BBLMySensorsTableViewCell"
    
    private static let kTableViewBackgroundImageName = "BBLMySensorsTableViewBackground"
    
    private struct FailedAddSensorAlert{
      private static let title = "Add Sensor to Profile Failed"
      private static let message = "Please make sure you have an active internet conection"
    }
    
    private struct FailedRemoveSensorAlert{
      private static let title = "Remove Sensor from Profile Failed"
      private static let message = "Please make sure you have an active internet conection"
    }
    
  }
  
  // MARK: Public Variables
  
  internal weak var loggedInParent: BBLParent!
  internal var sensorManager: BBLSensorManager!
  
  // MARK: Private Variables
  
  private var mySensors: [BBLSensor]!
  
  // MARK: Interface Builder
  
  @IBOutlet weak var mySensorsTableView: UITableView!
  
  @IBAction func didTapAddSensorButton(sender: UIButton) {
    
    let connectionVC = BBLConnectionViewController()
    connectionVC.sensorManager = sensorManager
    connectionVC.delegate = self
    
    let navController = UINavigationController(rootViewController: connectionVC)
    presentViewController(navController, animated: true, completion: nil)
    
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    setupParent(loggedInParent)
    setupTableView(mySensorsTableView)
    setupNavigationItem(navigationItem)

  }
  
  override func viewDidAppear(animated: Bool) {
    mySensorsTableView.reloadData()
  }
  
  // MARK: Setup
  
  private func setupParent(parent: BBLParent) {
    parent.delegate = self
  }
  
  private func setupTableView(tableView: UITableView) {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: BBLMySensorsViewControllerConstants.kMySensorsTVCNibName,
                                 bundle: NSBundle.mainBundle()),
                      forCellReuseIdentifier: BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    let backgroundView = NSBundle.mainBundle().loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil).first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    updateTableView()
  }
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    
    BBLsetupHamburgerMenuForNavItem(navItem)
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
  }
  
  private func updateTableView() {
    mySensors = loggedInParent.profileSensors.allObjects as? [BBLSensor]
    mySensorsTableView.reloadData()
  }
  
  private func updateTableViewCellSensorValueForSensor(sensor: BBLSensor) {
    
    let mySensorsSet = NSSet(array: mySensors)
    
    if mySensorsSet.isEqualToSet(loggedInParent.profileSensors as Set<NSObject>) {
      let row = mySensors.indexOf(sensor)
      let indexPath = NSIndexPath(forRow: row!, inSection: 0)
      
      let cell = mySensorsTableView.cellForRowAtIndexPath(indexPath) as!BBLMySensorsTableViewCell
      cell.updateValuesWithSensor(sensor)
    } else {
      updateTableView()
    }

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

extension BBLMySensorsViewController: UITableViewDelegate {
  
}

// MARK: UITableViewDataSource

extension BBLMySensorsViewController: UITableViewDataSource {
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let mySensors = mySensors else {
      return 0
    }
    return mySensors.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier, forIndexPath: indexPath) as! BBLMySensorsTableViewCell
    
    cell.delegate = self
    cell.sensor = mySensors[indexPath.row]
    cell.sensor.delegate = self
    
    return cell
  }
}

// MARK: BBLMySensorsTableViewCellDelegate

extension BBLMySensorsViewController: BBLMySensorsTableViewCellDelegate {
  internal func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: UInt, andName name: String?) {
    tableViewCell.sensor.capSenseThreshold = threshold
    tableViewCell.sensor.name = name
    tableViewCell.sensor.saveInBackgroundWithBlock { (succes: Bool, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  internal func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool) {
    loggedInParent.removeSensor(tableViewCell.sensor)
    tableViewCell.sensor.disconnect()
  }
  
  internal func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: UInt) {
    tableViewCell.sensor.capSenseThreshold = threshold
  }
  
  internal func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int) {
    tableViewCell.sensor.delayInSeconds = value
    updateTableView()
  }
  
  internal func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool) {
    tableViewCell.sensor.rebaseline()
  }
  
  internal func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero
    
  }
  
  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let sensorDetailVC = BBLSensorDetailViewController()
    sensorDetailVC.sensor = mySensors[indexPath.row]
    
    navigationController?.pushViewController(sensorDetailVC, animated: true)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
}

// MARK: BBLParentDelegate

extension BBLMySensorsViewController: BBLParentDelegate {
  internal func parent(parent: BBLParent, didAddSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func parent(parent: BBLParent, didFailAddSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLMySensorsViewControllerConstants.FailedAddSensorAlert.title, withMessage: BBLMySensorsViewControllerConstants.FailedAddSensorAlert.message + " " + errorMessage)
  }
  
  internal func parent(parent: BBLParent, didRemoveSensor sensor: BBLSensor) {
    navigationController?.popToRootViewControllerAnimated(true)
    updateTableView()
  }
  
  internal func parent(parent: BBLParent, didFailRemoveSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLMySensorsViewControllerConstants.FailedRemoveSensorAlert.title, withMessage: BBLMySensorsViewControllerConstants.FailedRemoveSensorAlert.message + " " + errorMessage)
  }
  
}

// MARK: BBLSensorDelegate

extension BBLMySensorsViewController: BBLSensorDelegate {
  internal func sensor(sensor: BBLSensor, didUpdateSensorValue value: UInt) {
    updateTableViewCellSensorValueForSensor(sensor)
  }
  
  internal func sensor(sensor: BBLSensor, didChangeState state: BBLSensorState) {
    updateTableViewCellSensorValueForSensor(sensor)
  }
  
  internal func sensor(sensor: BBLSensor, didDidFailToDeleteSensorWithErrorMessage errorMessage: String) {
    //TODO: Handle displaying this error.
  }
  
  internal func sensor(sensor: BBLSensor, didUpdateRSSI rssi: NSNumber) {
    updateTableView()
  }
  
}

// MARK: BBLConnectionViewControllerDelegate

extension BBLMySensorsViewController: BBLConnectionViewControllerDelegate {
  
  func connectionViewController(connectionVC: BBLConnectionViewController, didTapBackButton backButton: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func connectionViewController(connectionVC: BBLConnectionViewController, didFinishAddingSensor success: Bool) {
    dismissViewControllerAnimated(true, completion: nil)
  }

}
