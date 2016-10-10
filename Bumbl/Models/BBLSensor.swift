//
//  BBLSensor.swift
//  Bumbl
//
//  Created by Randy Ting on 1/12/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


internal enum BBLSensorState {
  case disconnected, deactivated, waitingToBeActivated, activated, waitingToBeDeactivated
}

protocol BBLSensorDelegate: class {
  func sensor(_ sensor: BBLSensor, didUpdateRSSI rssi: NSNumber)
  func sensor(_ sensor: BBLSensor, didUpdateSensorValue value: UInt)
  func sensor(_ sensor: BBLSensor, didDidFailToDeleteSensorWithErrorMessage errorMessage: String)
  func sensor(_ sensor: BBLSensor, didChangeState state: BBLSensorState)
}

internal final class BBLSensor: PFObject, PFSubclassing {
  
  private static var __once: () = {
    registerSubclass()
  }()
  
  // MARK: Constants
  
  fileprivate struct BBLSensorConstants {
    fileprivate static let defaultName = "Please Enter Baby Name"
  }
  
  // MARK: PFObject Subclassing
  
  override class func initialize() {
    struct Static {
      static var onceToken : Int = 0;
    }
    _ = BBLSensor.__once
  }
  
  static func parseClassName() -> String {
    return "BabySensor"
  }
  
  // MARK: Public Variables
  @NSManaged internal var name: String?
  @NSManaged fileprivate(set) var uuid: String?
  @NSManaged internal var capSenseThreshold:UInt
  @NSManaged internal var delayInSeconds:Int
  @NSManaged fileprivate(set) var connectedParent:BBLParent?
  @NSManaged internal var avatar: Int
  internal weak var delegate: BBLSensorDelegate?
  internal var rssi: NSNumber?
  internal var peripheral:CBPeripheral?
  internal weak var sensorManager: BBLSensorManager!
  internal var stateMachine:BBLStateMachine<BBLSensor>!
  var stateAsString: String! {
    get {
      switch (stateMachine.state) {
      case .activated:
        return "Armed (child in seat)"
      case .deactivated:
        return "Connected (no child)"
      case .disconnected:
        return "Disconnected"
      case .waitingToBeActivated:
        return "Arming..."
      case .waitingToBeDeactivated:
        return "Disarming..."
      }
    }
  }
  
  fileprivate var hasBaby:Bool {
    get {
      if let _ = capSenseValue {
        return capSenseValue > capSenseThreshold
      } else {
        return false // If no strain gauge value read
      }
    }
    set {
      self.hasBaby = newValue
    }
  }
  
  // MARK: Private Variables
  
  @NSManaged fileprivate var parentsCount: Int
  fileprivate var countdownTimer:Timer!
  fileprivate(set) var capSenseValue:UInt?
  fileprivate var rebaselineCharacteristic: CBCharacteristic?
  fileprivate var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0
  fileprivate var countdownAlert: BBLCountdownAlert?
  
  // MARK: Initialization
  
  // Designated initializer
  internal convenience init(withPeripheral peripheral: CBPeripheral?,
                            withSensorManager sensorManager: BBLSensorManager!,
                            withUUID uuid: String!,
                            withCapSenseThreshold capSenseThreshold: UInt,
                            withDelayInSeconds delayInSeconds: Int,
                            withDelegate delegate: BBLSensorDelegate?) {
    self.init()
    self.peripheral = peripheral
    self.sensorManager = sensorManager
    self.uuid = uuid
    self.capSenseThreshold = capSenseThreshold
    self.delegate = delegate
    self.name = BBLSensorConstants.defaultName
    self.delayInSeconds = delayInSeconds
    peripheral?.delegate = self
    self.stateMachine = BBLStateMachine(initialState: .disconnected, delegate: self)
  }
  
  // MARK: Class Methods
  
  // Class initializer for instantiating an existing peripheral loaded from the server or persistent storage.
  class func  sensorWith(_ peripheral: CBPeripheral?,
                         withSensorManager sensorManager: BBLSensorManager!,
                         withfromJSONDictionary dictionary: [String:AnyObject]) -> BBLSensor {
    
    //TODO: Parse JSON and initialize values
    let uuidFromJSON = "someUniqueIdentifier"
    let capSenseThreshFromJSON: UInt = 30
    let delayInSecondsFromJSON = 3
    return BBLSensor.init(withPeripheral: peripheral,
                          withSensorManager: sensorManager,
                          withUUID: uuidFromJSON,
                          withCapSenseThreshold: capSenseThreshFromJSON,
                          withDelayInSeconds: delayInSecondsFromJSON,
                          withDelegate: nil)
    
  }
  
  // Class initializer for instantating a sensor from connection.
  class func  sensorWith(_ peripheral: CBPeripheral!,
                         withSensorManager sensorManager: BBLSensorManager!) -> BBLSensor {
    
    return BBLSensor.init(withPeripheral: peripheral,
                          withSensorManager: sensorManager,
                          withUUID: peripheral.name,
                          withCapSenseThreshold: BBLSensorInfo.kDefaultCapSenseThreshold,
                          withDelayInSeconds: BBLSensorInfo.kDefaultDelayInSeconds,
                          withDelegate: nil)
  }
  
  // MARK: Parents Count
  
  internal func incrementParentsCount() {
    parentsCount += 1
  }
  
  internal func decrementParentsCount() {
    parentsCount -= 1
    if parentsCount == 0 {
      deleteInBackground(block: { (success: Bool, error: Error?) -> Void in
        if let error = error {
          self.delegate?.sensor(self, didDidFailToDeleteSensorWithErrorMessage: error.localizedDescription)
        }
      })
    }
  }
  
  // MARK: Connection
  
  internal func connect() {
    if let _ = self.peripheral {
      sensorManager.connectToSensor(self)
    }
  }
  
  internal func disconnect() {
    if let _ = self.peripheral {
      if (sensorManager.state == .poweredOff) {
        stateMachine.state = .disconnected
      }
      sensorManager.disconnectSensor(self)
    }
  }
  
  internal func onDidConnect() {
    stateMachine.state = .deactivated
  }
  
  internal func onDidDisconnect() {
    stateMachine.state = .disconnected
  }
  
  fileprivate func alertUserWithMessage(_ message: String, andTitle title:String) {
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = name! + message
    content.sound = UNNotificationSound.default()
    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: "hello", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request){(error) in
      if (error != nil){
        //TODO: Handle any errors with adding request
      }
    }
    
  }
  
  fileprivate func startCountdownAlert() {
    
    countdownAlert = BBLCountdownAlert(withStartTimeInSeconds: 10, withDelegate: self)
    
  }
  
  internal func updateToDisconnectedState() {
    connectedParent = nil
  }
  
  // MARK: Access
  
  internal func rebaseline() {
    if let rebaselineCharacteristic = rebaselineCharacteristic {
      peripheral?.writeValue(BBLSensorInfo.kRebaselineValue!, for: rebaselineCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
  }
  
}

// MARK: CBPeripheralDelegate

extension BBLSensor: CBPeripheralDelegate {
  
  internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    let uuid = characteristic.uuid
    
    if uuid == BBLSensorInfo.kCapSenseValueCharacteristicUUID {
      var value: UInt = 0
      (characteristic.value?.BBLswapUInt16Data() as NSData?)?.getBytes(&value, length: 2)
      capSenseValue = value
      
      delegate?.sensor(self, didUpdateSensorValue: capSenseValue!)
      
      switch (stateMachine.state as BBLSensorState) {
      case .deactivated:
        if hasBaby { stateMachine.state = .waitingToBeActivated }
      case .waitingToBeActivated:
        if !hasBaby {
          stateMachine.state = .deactivated
          stopCountdownTimer(countdownTimer)
        }
      case .activated:
        if !hasBaby { stateMachine.state = .waitingToBeDeactivated }
      case .waitingToBeDeactivated:
        if hasBaby {
          stateMachine.state = .activated
          stopCountdownTimer(countdownTimer)
        }
      default:
        // Do nothing
        break
      }
    }
  }
  
  internal func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    rssi = RSSI
  }
  
  internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    peripheral.discoverCharacteristics([BBLSensorInfo.kCapSenseValueCharacteristicUUID, BBLSensorInfo.kCapSenseValueCharacteristicUUID], for: (peripheral.services?.first)!)
  }
  
  internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.uuid == BBLSensorInfo.kCapSenseValueCharacteristicUUID {
          peripheral.setNotifyValue(true, for: characteristic)
          rebaselineCharacteristic = characteristic
        }
      }
    }
    
  }
  
  internal func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print(error.localizedDescription + " Failed to write to characteristic: " + characteristic.description)
    }
  }
  
}

// MARK: BBLStateMachineDelegate

extension BBLSensor:BBLStateMachineDelegateProtocol{
  typealias StateType = BBLSensorState
  
  internal func shouldTransitionFrom(_ from:StateType, to:StateType)->Bool{
    switch (from, to){
    case (.disconnected, .deactivated),
         (.deactivated, .disconnected),
         (.deactivated, .waitingToBeActivated),
         (.waitingToBeActivated, .deactivated),
         (.waitingToBeActivated, .activated),
         (.activated, .waitingToBeDeactivated),
         (.waitingToBeDeactivated, .activated),
         (.waitingToBeDeactivated, .deactivated):
      return true
    case (_, .disconnected):
      return true
    default:
      return false
    }
  }
  
  internal func didTransitionFrom(_ from:StateType, to:StateType){
    switch (from, to){
      
    case (.disconnected, .deactivated):
      connectedParent = BBLParent.loggedInParent()
      
      if sensorManager.state != .poweredOn {
        sensorManager.peripheralsToDiscoverServices.insert(peripheral!)
      } else {
        peripheral!.discoverServices([BBLSensorInfo.kSensorServiceUUID])
      }
      peripheral!.delegate = self
      // TODO: Start timer to poll for RSSI on connection.  Stop timer on disconnect.
      
    case (.deactivated, .waitingToBeActivated):
      startCountdownForTimeInSeconds(delayInSeconds)
      
    case (.activated, .waitingToBeDeactivated):
      startCountdownForTimeInSeconds(delayInSeconds)
      
    case (.waitingToBeActivated, .activated):
      alertUserWithMessage(BBLSensorInfo.Alerts.sensorActivatedAlertMessage, andTitle: BBLSensorInfo.Alerts.sensorActivatedAlertTitle)
      if let capSenseValue = capSenseValue {
        BBLActivityLogger.sharedInstance.logSensorValue(capSenseValue, forSensor: self, forEvent: BBLActivityLogger.Event.Activated)
      }
      
    case (.waitingToBeDeactivated, .deactivated):
      alertUserWithMessage(BBLSensorInfo.Alerts.sensorDeactivatedAlertMessage, andTitle: BBLSensorInfo.Alerts.sensorDeactivatedAlertTitle)
      if let capSenseValue = capSenseValue {
        BBLActivityLogger.sharedInstance.logSensorValue(capSenseValue, forSensor: self, forEvent: BBLActivityLogger.Event.Deactivated)
      }
      
    case (.activated, .disconnected):
      afterDisconnection()
      alertUserWithMessage(BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertMessage, andTitle: BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertTitle)
      startCountdownAlert()
      if let capSenseValue = capSenseValue {
        BBLActivityLogger.sharedInstance.logSensorValue(capSenseValue, forSensor: self, forEvent: BBLActivityLogger.Event.Disconnected)
      }
      
    case (.waitingToBeDeactivated, .disconnected):
      afterDisconnection()
      alertUserWithMessage(BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertMessage, andTitle: BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertTitle)
      startCountdownAlert()
      if let capSenseValue = capSenseValue {
        BBLActivityLogger.sharedInstance.logSensorValue(capSenseValue, forSensor: self, forEvent: BBLActivityLogger.Event.Disconnected)
      }
      
    case (_, .disconnected):
      afterDisconnection()
      if let capSenseValue = capSenseValue {
        BBLActivityLogger.sharedInstance.logSensorValue(capSenseValue, forSensor: self, forEvent: BBLActivityLogger.Event.Disconnected)
      }
      
    default:
      break
    }
    
    delegate?.sensor(self, didChangeState: to)
    
  }
  
  fileprivate func afterDisconnection(){
    stopCountdownTimer(countdownTimer)
    connectedParent = nil
    saveInBackground { (success: Bool, error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
}

// MARK: Timer

extension BBLSensor {
  fileprivate func startCountdownForTimeInSeconds(_ seconds: Int) {
    countdownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(BBLSensor.countdownEnded(_:)), userInfo: nil, repeats: false)
  }
  
  internal func countdownEnded(_ timer: Timer) {
    switch stateMachine.state {
    case .waitingToBeActivated:
      stateMachine.state = .activated
    case .waitingToBeDeactivated:
      stateMachine.state = .deactivated
    default:
      print("Sensor countdown ended from a state that is not WaitingToBeActivated or WaitingToBeDeactivated.")
    }
    
    stopCountdownTimer(timer)
  }
  
  fileprivate func stopCountdownTimer(_ timer: Timer?) {
    if let timer = timer {
      timer.invalidate()
    }
  }
}

// MARK: BBLCountdownAlert Delegate

extension BBLSensor: BBLCountdownAlertDelegate {
  
  internal func countdownAlert(_ alert: BBLCountdownAlert, didEnd end: Bool) {
    
    print("Countdown done!")
  }
  
}
