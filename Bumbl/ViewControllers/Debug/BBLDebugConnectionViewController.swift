//
//  BBLDebugConnectionViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLDebugConnectionViewController: UIViewController {
  
  // MARK: Constants
  private struct BBLDebugConnectionViewControllerConstants {
    private static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    
    private struct FailedConnectionAlert{
      private static let title = "Connection Failed"
      private static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
    
    private static let noDiscoveredSensorsMessage = "No sensors discovered.  Please make sure you are near a sensor that is turned on and not connected to a phone."
  }
  
  // MARK: Interface Builder
  @IBOutlet private weak var connectionTableView: UITableView!
  @IBOutlet private weak var noDiscoveredSensorsLabel: UILabel!
  
  // MARK: Instance Variables
  internal var sensorManager: BBLSensorManager!
  
  // MARK: Private Variables
  private var discoveredSensors: [BBLSensor]!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSensorManager(sensorManager)
    setupEmptyTableViewCover(noDiscoveredSensorsLabel)
    setupTableView(connectionTableView)
  }
  
  // MARK: Tableview
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BBLDebugConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
    tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    updateTableView()
  }
  
  private func setupSensorManager(sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
  }
  
  private func updateTableView() {
    discoveredSensors = Array(sensorManager.discoveredSensors)
    if discoveredSensors.count == 0 ||
    discoveredSensors == nil{
      noDiscoveredSensorsLabel.hidden = false
    } else {
      noDiscoveredSensorsLabel.hidden = true
    }
    connectionTableView.reloadData()
  }
  
  private func setupEmptyTableViewCover(view: UILabel) {
    view.backgroundColor = UIColor.BBLGrayColor()
    view.textColor = UIColor.BBLYellowColor()
    view.numberOfLines = 0
    view.text = BBLDebugConnectionViewControllerConstants.noDiscoveredSensorsMessage
  }
}

// MARK: UITableViewDelegate
extension BBLDebugConnectionViewController: UITableViewDelegate {

  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    discoveredSensors[indexPath.row].connect()
  }
}

// MARK: UITableViewDatasource
extension BBLDebugConnectionViewController: UITableViewDataSource {
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let discoveredSensors = discoveredSensors else {
      return 0
    }
    return discoveredSensors.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLDebugConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, forIndexPath: indexPath)
    
    cell.textLabel!.text = discoveredSensors[indexPath.row].uuid
    
    return cell
  }
  
}

// MARK: BBLSensorManagerDelegate
extension BBLDebugConnectionViewController:BBLSensorManagerDelegate {
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
    
    let alertController = UIAlertController(title: BBLDebugConnectionViewControllerConstants.FailedConnectionAlert.title, message: BBLDebugConnectionViewControllerConstants.FailedConnectionAlert.message, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alertController.addAction(dismissAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
}