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
  fileprivate struct BBLDebugConnectionViewControllerConstants {
    fileprivate static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    
    fileprivate struct FailedConnectionAlert{
      fileprivate static let title = "Connection Failed"
      fileprivate static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
    
    fileprivate static let noDiscoveredSensorsMessage = "No sensors discovered.  Please make sure you are near a sensor that is turned on and not connected to a phone."
  }
  
  // MARK: Interface Builder
  @IBOutlet fileprivate weak var connectionTableView: UITableView!
  @IBOutlet fileprivate weak var noDiscoveredSensorsLabel: UILabel!
  
  // MARK: Instance Variables
  internal var sensorManager: BBLSensorManager!
  
  // MARK: Private Variables
  fileprivate var discoveredSensors: [BBLSensor]!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSensorManager(sensorManager)
    setupEmptyTableViewCover(noDiscoveredSensorsLabel)
    setupTableView(connectionTableView)
  }
  
  // MARK: Tableview
  fileprivate func setupTableView(_ tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: BBLDebugConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
    tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    updateTableView()
  }
  
  fileprivate func setupSensorManager(_ sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
  }
  
  fileprivate func updateTableView() {
    discoveredSensors = Array(sensorManager.discoveredSensors)
    if discoveredSensors.count == 0 ||
    discoveredSensors == nil{
      noDiscoveredSensorsLabel.isHidden = false
    } else {
      noDiscoveredSensorsLabel.isHidden = true
    }
    connectionTableView.reloadData()
  }
  
  fileprivate func setupEmptyTableViewCover(_ view: UILabel) {
    view.backgroundColor = UIColor.BBLGrayColor()
    view.textColor = UIColor.BBLYellowColor()
    view.numberOfLines = 0
    view.text = BBLDebugConnectionViewControllerConstants.noDiscoveredSensorsMessage
  }
}

// MARK: UITableViewDelegate
extension BBLDebugConnectionViewController: UITableViewDelegate {

  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    discoveredSensors[(indexPath as NSIndexPath).row].connect()
  }
}

// MARK: UITableViewDatasource
extension BBLDebugConnectionViewController: UITableViewDataSource {
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let discoveredSensors = discoveredSensors else {
      return 0
    }
    return discoveredSensors.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: BBLDebugConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, for: indexPath)
    
    cell.textLabel!.text = discoveredSensors[(indexPath as NSIndexPath).row].uuid
    
    return cell
  }
  
}

// MARK: BBLSensorManagerDelegate
extension BBLDebugConnectionViewController:BBLSensorManagerDelegate {
  internal func sensorManager(_ sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(_ sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(_ sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor) {
    updateTableView()
  }
  
  internal func sensorManager(_ sensorManager: BBLSensorManager, didFailToConnectToSensor sensor: BBLSensor) {
    updateTableView()
    showConnectionFailedAlert()
  }
  
  fileprivate func showConnectionFailedAlert() {
    
    let alertController = UIAlertController(title: BBLDebugConnectionViewControllerConstants.FailedConnectionAlert.title, message: BBLDebugConnectionViewControllerConstants.FailedConnectionAlert.message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }
}
