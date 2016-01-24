//
//  BBLMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLMySensorsViewController: UIViewController {

// MARK: Constants
  private struct BBLMySensorsViewControllerConstants {
    private static let kMySensorsTVCReuseIdentifier = "com.randy.mySensorsTVCReuseIdentifier"
    
    private static let noProfileSensorsMessage = "No sensors were found in your profile.  Please add a sensor to your profile by connecting to one."
  }
  
// MARK: Interface Builder
  @IBOutlet weak var mySensorsTableView: UITableView!
  @IBOutlet weak var noProfileSensorsLabel: UILabel!
  
// MARK: Public Variables
  internal var loggedInParent:BBLParent!
  internal var sensorManager: BBLSensorManager!

// MARK: Private Variables
  private var mySensors: [BBLSensor]!
  
// MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableView(mySensorsTableView)
    setupSensorManager(sensorManager)
    setupEmptyTableViewCover(noProfileSensorsLabel)
  }
  
// MARK: Setup
  private func setupSensorManager(sensorManger: BBLSensorManager) {
    sensorManager.registerDelegate(self)
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "didTapLogout")
  }
  
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier)
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
    view.text = BBLMySensorsViewControllerConstants.noProfileSensorsMessage
  }

// MARK: Navigation Bar
  internal func didTapLogout() {
    NSNotificationCenter.defaultCenter().postNotificationName(BBLNotifications.kParentDidLogoutNotification, object: self)
  }
  
}

// MARK: UITableViewDelegate
extension BBLMySensorsViewController:UITableViewDelegate {
  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    loggedInParent.removeSensor(mySensors[indexPath.row])
    mySensors[indexPath.row].disconnect()
  }
}

// MARK: UITableViewDatasource
extension BBLMySensorsViewController:UITableViewDataSource {
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let mySensors = mySensors else {
      return 0
    }
    return mySensors.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier, forIndexPath: indexPath)
    
    cell.textLabel!.text = mySensors[indexPath.row].peripheral?.identifier.UUIDString
    
    return cell
  }
}

// MARK: BBLSensorManagerDelegate
extension BBLMySensorsViewController: BBLSensorManagerDelegate {
  internal func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    if loggedInParent.profileSensors.containsObject(sensor) {
      updateTableView()
    } else {
      // (RT) This is a hack because parent may not have added sensor to array yet.  No guarantees on which delegate method gets called first in a multicast delegate pattern.
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.updateTableView()
      }
    }
    
  }
  
  internal func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    updateTableView()
  }
}