//
//  BBLConnectionViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLConnectionViewControllerDelegate: class {
  func connectionViewController(connectionVC: BBLConnectionViewController, didTapBackButton backButton: UIButton)
  func connectionViewController(connectionVC: BBLConnectionViewController, didFinishAddingSensor success: Bool)
}

class BBLConnectionViewController: UIViewController {
  
  // MARK: Constants
  private struct BBLConnectionViewControllerConstants {
    private static let kTitle = "DISCOVER SENSORS"
    
    private static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    
    private struct FailedConnectionAlert{
      private static let title = "Connection Failed"
      private static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
    
    private static let noDiscoveredSensorsMessage = "No sensors discovered.  Please make sure you are near a sensor that is turned on and not connected to a phone."
  }
  
  // MARK: Interface Builder
  @IBOutlet private weak var connectionTableView: UITableView!
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  
  @IBAction func didTapBackButton(sender: BBLModalBottomButton) {
    delegate?.connectionViewController(self, didTapBackButton: sender)
  }
  
  // MARK: Instance Variables
  internal var sensorManager: BBLSensorManager!
  internal weak var delegate: BBLConnectionViewControllerDelegate?
  
  // MARK: Private Variables
  private var discoveredSensors: [BBLSensor]!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = BBLConnectionViewControllerConstants.kTitle
    setupSensorManager(sensorManager)
    setupEmptyTableViewCover(activityIndicatorView)
    setupTableView(connectionTableView)
  }
  
  deinit {
    sensorManager.unregisterDelegate(self)
  }
  
  // MARK: Tableview
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
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
      activityIndicatorView.hidden = false
    } else {
      activityIndicatorView.hidden = true
    }
    connectionTableView.reloadData()
  }
  
  private func setupEmptyTableViewCover(view: UIActivityIndicatorView) {
    view.backgroundColor = UIColor.BBLGrayColor()
    view.startAnimating()
  }
}

// MARK: UITableViewDelegate
extension BBLConnectionViewController: UITableViewDelegate {
  
  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    discoveredSensors[indexPath.row].connect()
  }
}

// MARK: UITableViewDatasource
extension BBLConnectionViewController: UITableViewDataSource {
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let discoveredSensors = discoveredSensors else {
      return 0
    }
    return discoveredSensors.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, forIndexPath: indexPath)
    
    cell.textLabel!.text = discoveredSensors[indexPath.row].uuid
    
    return cell
  }
  
}

// MARK: BBLSensorManagerDelegate
extension BBLConnectionViewController:BBLSensorManagerDelegate {
  internal func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    updateTableView()
    
    let addSensorVC = BBLAddSensorViewController()
    addSensorVC.sensor = sensor
    addSensorVC.delegate = self
    
    navigationController?.pushViewController(addSensorVC, animated: true)
    
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

// MARK: BBLEditSensorViewControllerDelegate

extension BBLConnectionViewController: BBLEditSensorViewControllerDelegate {
  
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapCancelButton bottomButton: UIBarButtonItem) {
    delegate?.connectionViewController(self, didFinishAddingSensor: false)
  }
  
  func BBLEditSensorVC(vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton) {
    delegate?.connectionViewController(self, didFinishAddingSensor: true)
  }
}
