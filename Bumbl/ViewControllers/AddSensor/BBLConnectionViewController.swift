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
    private static let kTitle = "Device Found"
    
    private static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    private static let kConnectionTVCNibName = "BBLConnectionTableViewCell"
    
    private struct FailedConnectionAlert{
      private static let title = "Connection Failed"
      private static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
    
    private static let noDiscoveredSensorsMessage = "No sensors discovered.  Please make sure you are near a sensor that is turned on and not connected to a phone."
  }
  
  // MARK: Interface Builder
  @IBOutlet private weak var connectionTableView: UITableView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var beeLogoAlignCenterConstraint: NSLayoutConstraint!
  @IBOutlet weak var loadingMessageLabel: UILabel!
  @IBOutlet weak var tableViewTopToSuperviewConstraint: NSLayoutConstraint!
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
    BBLsetupBlueNavigationBar(navigationController?.navigationBar)
    setupAnimationForBeeLogoConstraint(beeLogoAlignCenterConstraint)
    setupAppearanceForLoadingMessage(loadingMessageLabel)
    setupSensorManager(sensorManager)
    setupTableView(connectionTableView)
    setupTopPositionConstraint(tableViewTopToSuperviewConstraint)
  }
  
  deinit {
    sensorManager.unregisterDelegate(self)
  }
  
  // MARK: Setup
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: BBLConnectionViewControllerConstants.kConnectionTVCNibName,
                                  bundle: NSBundle.mainBundle()),
              forCellReuseIdentifier: BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
    tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    tableView.separatorStyle = .None
    tableView.backgroundColor = UIColor.clearColor()
    
    let backgroundView = NSBundle.mainBundle().loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil).first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    updateTableView()
  }
  
  private func setupSensorManager(sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
  }
  
  private func updateTableView() {
    discoveredSensors = Array(sensorManager.discoveredSensors)
    if discoveredSensors.count == 0 ||
      discoveredSensors == nil{
      loadingView.hidden = false
    } else {
      loadingView.hidden = true
    }
    connectionTableView.reloadData()
  }
  
  private func setupAnimationForBeeLogoConstraint(constraint: NSLayoutConstraint) {
    UIView.animateWithDuration(1.0, delay: 0.0, options: [.Repeat, .Autoreverse, .CurveEaseInOut], animations: {
      constraint.constant = constraint.constant - 50.0
      self.loadingView.layoutIfNeeded()
      }, completion: nil)
  }
  
  private func setupTopPositionConstraint(constraint: NSLayoutConstraint) {
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 20
    }
  }
  
  private func setupAppearanceForLoadingMessage(label: UILabel) {
    label.textColor = UIColor.BBLDarkBlueColor()
    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(BBLConnectionViewController.updateLoadingMessage), userInfo: nil, repeats: true)
  }
  
  internal func updateLoadingMessage() {
    switch loadingMessageLabel.text! {
    case "Looking for nearby sensors...":
      loadingMessageLabel.text = "Looking for nearby sensors"
    case "Looking for nearby sensors":
      loadingMessageLabel.text = "Looking for nearby sensors."
    case "Looking for nearby sensors.":
      loadingMessageLabel.text = "Looking for nearby sensors.."
    default:
      loadingMessageLabel.text = "Looking for nearby sensors..."
    }
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
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, forIndexPath: indexPath) as! BBLConnectionTableViewCell
    
    cell.textField.text = discoveredSensors[indexPath.row].uuid!
    cell.textField.textField.userInteractionEnabled = false
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
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
