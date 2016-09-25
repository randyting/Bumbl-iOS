//
//  BBLMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLMySensorsViewController: BBLViewController {
  
  // MARK: Constants
  
  fileprivate struct BBLMySensorsViewControllerConstants {
    
    fileprivate static let kMySensorsTVCReuseIdentifier = "com.randy.mySensorsTVCReuseIdentifier"
    fileprivate static let kMySensorsTVCNibName = "BBLMySensorsTableViewCell"
    
    fileprivate static let kTableViewBackgroundImageName = "BBLMySensorsTableViewBackground"
    
    fileprivate struct FailedAddSensorAlert{
      fileprivate static let title = "Add Sensor to Profile Failed"
      fileprivate static let message = "Please make sure you have an active internet conection"
    }
    
    fileprivate struct FailedRemoveSensorAlert{
      fileprivate static let title = "Remove Sensor from Profile Failed"
      fileprivate static let message = "Please make sure you have an active internet conection"
    }
    
  }
  
  // MARK: Public Variables
  
  internal weak var loggedInParent: BBLParent!
  internal var sensorManager: BBLSensorManager!
  
  // MARK: Private Variables
  
  fileprivate var mySensors: [BBLSensor]!
  
  // MARK: Interface Builder
  
  @IBOutlet weak var mySensorsTableView: UITableView!
  
  @IBAction func didTapAddSensorButton(_ sender: UIButton) {
    
    let connectionVC = BBLConnectionViewController()
    connectionVC.sensorManager = sensorManager
    connectionVC.delegate = self
    
    let navController = UINavigationController(rootViewController: connectionVC)
    present(navController, animated: true, completion: nil)
    
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    setupParent(loggedInParent)
    setupTableView(mySensorsTableView)
    setupNavigationItem(navigationItem)

  }
  
  override func viewDidAppear(_ animated: Bool) {
    mySensorsTableView.reloadData()
  }
  
  // MARK: Setup
  
  fileprivate func setupParent(_ parent: BBLParent) {
    parent.delegate = self
  }
  
  fileprivate func setupTableView(_ tableView: UITableView) {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: BBLMySensorsViewControllerConstants.kMySensorsTVCNibName,
                                 bundle: Bundle.main),
                      forCellReuseIdentifier: BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    let backgroundView = Bundle.main.loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil)?.first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    updateTableView()
  }
  
  fileprivate func setupNavigationItem(_ navItem: UINavigationItem) {
    
    BBLsetupHamburgerMenuForNavItem(navItem)
  }
  
  fileprivate func updateTableView() {
    mySensors = loggedInParent.profileSensors.allObjects as? [BBLSensor]
    mySensorsTableView.reloadData()
  }
  
  fileprivate func updateTableViewCellSensorValueForSensor(_ sensor: BBLSensor) {
    
    let mySensorsSet = NSSet(array: mySensors)
    
    if mySensorsSet.isEqual(to: loggedInParent.profileSensors as Set<NSObject>) {
      let row = mySensors.index(of: sensor)
      let indexPath = IndexPath(row: row!, section: 0)
      
      let cell = mySensorsTableView.cellForRow(at: indexPath) as!BBLMySensorsTableViewCell
      cell.updateValuesWithSensor(sensor)
    } else {
      updateTableView()
    }

  }
  
  // MARK: Alerts
  
  fileprivate func showDismissAlertWithTitle(_ title: String, withMessage message: String) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
}

// MARK: UITableViewDelegate

extension BBLMySensorsViewController: UITableViewDelegate {
  
}

// MARK: UITableViewDataSource

extension BBLMySensorsViewController: UITableViewDataSource {
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let mySensors = mySensors else {
      return 0
    }
    return mySensors.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier, for: indexPath) as! BBLMySensorsTableViewCell
    
    cell.delegate = self
    cell.sensor = mySensors[(indexPath as NSIndexPath).row]
    cell.sensor.delegate = self
    
    return cell
  }
}

// MARK: BBLMySensorsTableViewCellDelegate

extension BBLMySensorsViewController: BBLMySensorsTableViewCellDelegate {
  internal func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: UInt, andName name: String?) {
    tableViewCell.sensor.capSenseThreshold = threshold
    tableViewCell.sensor.name = name
    tableViewCell.sensor.saveInBackground { (succes: Bool, error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  internal func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool) {
    loggedInParent.removeSensor(tableViewCell.sensor)
    tableViewCell.sensor.disconnect()
  }
  
  internal func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: UInt) {
    tableViewCell.sensor.capSenseThreshold = threshold
  }
  
  internal func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int) {
    tableViewCell.sensor.delayInSeconds = value
    updateTableView()
  }
  
  internal func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool) {
    tableViewCell.sensor.rebaseline()
  }
  
  @objc(tableView:willDisplayCell:forRowAtIndexPath:) internal func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    tableView.separatorInset = UIEdgeInsets.zero
    tableView.layoutMargins = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
    
  }
  
  @objc(tableView:didSelectRowAtIndexPath:) internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sensorDetailVC = BBLSensorDetailViewController()
    sensorDetailVC.sensor = mySensors[(indexPath as NSIndexPath).row]
    
    navigationController?.pushViewController(sensorDetailVC, animated: true)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}

// MARK: BBLParentDelegate

extension BBLMySensorsViewController: BBLParentDelegate {
  internal func parent(_ parent: BBLParent, didAddSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func parent(_ parent: BBLParent, didFailAddSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLMySensorsViewControllerConstants.FailedAddSensorAlert.title, withMessage: BBLMySensorsViewControllerConstants.FailedAddSensorAlert.message + " " + errorMessage)
  }
  
  internal func parent(_ parent: BBLParent, didRemoveSensor sensor: BBLSensor) {
    let _ = navigationController?.popToRootViewController(animated: true)
    updateTableView()
  }
  
  internal func parent(_ parent: BBLParent, didFailRemoveSensor sensor: BBLSensor, withErrorMessage errorMessage: String) {
    updateTableView()
    showDismissAlertWithTitle(BBLMySensorsViewControllerConstants.FailedRemoveSensorAlert.title, withMessage: BBLMySensorsViewControllerConstants.FailedRemoveSensorAlert.message + " " + errorMessage)
  }
  
}

// MARK: BBLSensorDelegate

extension BBLMySensorsViewController: BBLSensorDelegate {
  internal func sensor(_ sensor: BBLSensor, didUpdateSensorValue value: UInt) {
    if let sensors = loggedInParent.sensors , sensors.contains(sensor){
      updateTableViewCellSensorValueForSensor(sensor)
    }
  }
  
  internal func sensor(_ sensor: BBLSensor, didChangeState state: BBLSensorState) {
    if let sensors = loggedInParent.sensors , sensors.contains(sensor){
      updateTableViewCellSensorValueForSensor(sensor)
    }
  }
  
  internal func sensor(_ sensor: BBLSensor, didDidFailToDeleteSensorWithErrorMessage errorMessage: String) {
    //TODO: Handle displaying this error.
  }
  
  internal func sensor(_ sensor: BBLSensor, didUpdateRSSI rssi: NSNumber) {
    updateTableView()
  }
  
}

// MARK: BBLConnectionViewControllerDelegate

extension BBLMySensorsViewController: BBLConnectionViewControllerDelegate {
  
  func connectionViewController(_ connectionVC: BBLConnectionViewController, didTapBackButton backButton: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  func connectionViewController(_ connectionVC: BBLConnectionViewController, didFinishAddingSensor success: Bool) {
    dismiss(animated: true, completion: nil)
  }

}
