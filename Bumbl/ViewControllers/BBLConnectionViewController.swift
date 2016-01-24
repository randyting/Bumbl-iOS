//
//  BBLConnectionViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLConnectionViewController: UIViewController {
  
  // MARK: Constants
  private struct BBLConnectionViewControllerConstants {
    private static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    
    private struct FailedConnectionAlert{
      private static let title = "Connection Failed"
      private static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
  }
  
  // MARK: Interface Builder
  @IBOutlet private weak var connectionTableView: UITableView!
  
  // MARK: Instance Variables
  internal var sensorManager: BBLSensorManager!
  
  // MARK: Private Variables
  private var discoveredSensors: [BBLSensor]!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView(connectionTableView)
    setupSensorManager(sensorManager)
  }
  
  // MARK: Tableview
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
    updateTableView()
  }
  
  private func setupSensorManager(sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
  }
  
  private func updateTableView() {
    discoveredSensors = Array(sensorManager.discoveredSensors)
    connectionTableView.reloadData()
  }
}

// MARK: UITableViewDelegate
extension BBLConnectionViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    //
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    discoveredSensors[indexPath.row].connect()
  }
}

// MARK: UITableViewDatasource
extension BBLConnectionViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return discoveredSensors.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, forIndexPath: indexPath)
    
    cell.textLabel!.text = discoveredSensors[indexPath.row].peripheral?.identifier.UUIDString
    
    return cell
  }
  
}

// MARK: BBLSensorManagerDelegate
extension BBLConnectionViewController:BBLSensorManagerDelegate {
  internal func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(sensorManager: BBLSensorManager, didFailToConnectToSensor sensor: BBLSensor) {
    updateTableView()
    showConnectionFailedAlert()
  }
  
  private func showConnectionFailedAlert() {
    
    let alertController = UIAlertController(title: BBLConnectionViewControllerConstants.FailedConnectionAlert.title, message: BBLConnectionViewControllerConstants.FailedConnectionAlert.message, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}