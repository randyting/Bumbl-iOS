//
//  BBLConnectionViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

protocol BBLConnectionViewControllerDelegate: class {
  func connectionViewController(_ connectionVC: BBLConnectionViewController, didTapBackButton backButton: UIButton)
  func connectionViewController(_ connectionVC: BBLConnectionViewController, didFinishAddingSensor success: Bool)
}

class BBLConnectionViewController: UIViewController {
  
  // MARK: Constants
  fileprivate struct BBLConnectionViewControllerConstants {
    fileprivate static let kTitle = "Device Found"
    
    fileprivate static let kConnectionViewTVCReuseIdentifier = "com.randy.connectionViewTVCReuseIdentifier"
    fileprivate static let kConnectionTVCNibName = "BBLConnectionTableViewCell"
    
    fileprivate struct FailedConnectionAlert{
      fileprivate static let title = "Connection Failed"
      fileprivate static let message = "Connection to this sensor failed.  Please check to make sure it is still advertising and in range."
    }
    
    fileprivate static let noDiscoveredSensorsMessage = "No sensors discovered.  Please make sure you are near a sensor that is turned on and not connected to a phone."
  }
  
  // MARK: Interface Builder
  @IBOutlet fileprivate weak var connectionTableView: UITableView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var beeLogoAlignCenterConstraint: NSLayoutConstraint!
  @IBOutlet weak var loadingMessageLabel: UILabel!
  @IBOutlet weak var tableViewTopToSuperviewConstraint: NSLayoutConstraint!
  @IBAction func didTapBackButton(_ sender: BBLModalBottomButton) {
    delegate?.connectionViewController(self, didTapBackButton: sender)
  }
  
  // MARK: Instance Variables
  internal var sensorManager: BBLSensorManager!
  internal weak var delegate: BBLConnectionViewControllerDelegate?
  
  // MARK: Private Variables
  fileprivate var discoveredSensors: [BBLSensor]!
  
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
  fileprivate func setupTableView(_ tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UINib(nibName: BBLConnectionViewControllerConstants.kConnectionTVCNibName,
                                  bundle: Bundle.main),
              forCellReuseIdentifier: BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier)
    tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    tableView.separatorStyle = .none
    tableView.backgroundColor = UIColor.clear
    
    let backgroundView = Bundle.main.loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil)?.first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    updateTableView()
  }
  
  fileprivate func setupSensorManager(_ sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
    sensorManager.scanForSensors()
  }
  
  fileprivate func updateTableView() {
    discoveredSensors = Array(sensorManager.discoveredSensors)
    if discoveredSensors.count == 0 ||
      discoveredSensors == nil{
      loadingView.isHidden = false
    } else {
      loadingView.isHidden = true
    }
    connectionTableView.reloadData()
  }
  
  fileprivate func setupAnimationForBeeLogoConstraint(_ constraint: NSLayoutConstraint) {
    UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
      constraint.constant = constraint.constant - 50.0
      self.loadingView.layoutIfNeeded()
      }, completion: nil)
  }
  
  fileprivate func setupTopPositionConstraint(_ constraint: NSLayoutConstraint) {
    if let navigationController = navigationController {
      constraint.constant = navigationController.navigationBar.bounds.height + 20
    }
  }
  
  fileprivate func setupAppearanceForLoadingMessage(_ label: UILabel) {
    label.textColor = UIColor.BBLDarkBlueColor()
    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BBLConnectionViewController.updateLoadingMessage), userInfo: nil, repeats: true)
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
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    discoveredSensors[(indexPath as NSIndexPath).row].connect()
  }
}

// MARK: UITableViewDatasource
extension BBLConnectionViewController: UITableViewDataSource {
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let discoveredSensors = discoveredSensors else {
      return 0
    }
    return discoveredSensors.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: BBLConnectionViewControllerConstants.kConnectionViewTVCReuseIdentifier, for: indexPath) as! BBLConnectionTableViewCell
    
    cell.textField.text = discoveredSensors[(indexPath as NSIndexPath).row].uuid!
    cell.textField.textField.isUserInteractionEnabled = false
    
    return cell
  }
  
  @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
}

// MARK: BBLSensorManagerDelegate
extension BBLConnectionViewController:BBLSensorManagerDelegate {
  internal func sensorManager(_ sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    updateTableView()
    
    let addSensorVC = BBLAddSensorViewController()
    addSensorVC.sensor = sensor
    addSensorVC.delegate = self
    
    navigationController?.pushViewController(addSensorVC, animated: true)
    
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
    
    let alertController = UIAlertController(title: BBLConnectionViewControllerConstants.FailedConnectionAlert.title, message: BBLConnectionViewControllerConstants.FailedConnectionAlert.message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alertController.addAction(dismissAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: BBLEditSensorViewControllerDelegate

extension BBLConnectionViewController: BBLEditSensorViewControllerDelegate {
  
  func BBLEditSensorVC(_ vc: BBLEditSensorViewController, didTapCancelButton bottomButton: UIBarButtonItem) {
    delegate?.connectionViewController(self, didFinishAddingSensor: false)
  }
  
  func BBLEditSensorVC(_ vc: BBLEditSensorViewController, didTapBottomButton bottomButton: BBLModalBottomButton) {
    delegate?.connectionViewController(self, didFinishAddingSensor: true)
  }
}
