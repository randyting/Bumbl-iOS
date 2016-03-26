//
//  BBLSensor.swift
//  Bumbl
//
//  Created by Randy Ting on 1/12/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import CoreBluetooth

internal enum BBLSensorState {
  case Disconnected, Deactivated, WaitingToBeActivated, Activated, WaitingToBeDeactivated
}

protocol BBLSensorDelegate: class {
  func sensor(sensor: BBLSensor, didUpdateRSSI rssi: NSNumber)
  func sensor(sensor: BBLSensor, didUpdateSensorValue value: Int)
  func sensor(sensor: BBLSensor, didDidFailToDeleteSensorWithErrorMessage errorMessage: String)
  func sensor(sensor: BBLSensor, didChangeState state: BBLSensorState)
}

internal final class BBLSensor: PFObject, PFSubclassing {
  
  // MARK: Constants
  
  private struct BBLSensorConstants {
    private static let defaultName = "Please Enter Baby Name"
  }
  
  // MARK: PFObject Subclassing
  
  override class func initialize() {
    struct Static {
      static var onceToken : dispatch_once_t = 0;
    }
    dispatch_once(&Static.onceToken) {
      self.registerSubclass()
    }
  }
  
  static func parseClassName() -> String {
    return "BabySensor"
  }
  
  // MARK: Public Variables
  @NSManaged internal var name: String?
  @NSManaged private(set) var uuid: String?
  @NSManaged internal var capSenseThreshold:Int
  @NSManaged internal var delayInSeconds:Int
  internal weak var delegate: BBLSensorDelegate?
  internal var rssi: NSNumber?
  internal var peripheral:CBPeripheral?
  internal weak var sensorManager: BBLSensorManager!
  internal var stateMachine:BBLStateMachine<BBLSensor>!
  
  private var hasBaby:Bool {
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
  
  @NSManaged private var connectedParent:BBLParent?
  @NSManaged private var parentsCount: Int
  private var countdownTimer:NSTimer!
  private(set) var capSenseValue:Int?
  private var rebaselineCharacteristic: CBCharacteristic?
  
  // MARK: Initialization
  
  // Designated initializer
  internal convenience init(withPeripheral peripheral: CBPeripheral?,
    withSensorManager sensorManager: BBLSensorManager!,
    withUUID uuid: String!,
    withCapSenseThreshold capSenseThreshold: Int,
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
      self.stateMachine = BBLStateMachine(initialState: .Disconnected, delegate: self)
  }
  
  // MARK: Class Methods
  
  // Class initializer for instantiating an existing peripheral loaded from the server or persistent storage.
  class func  sensorWith(peripheral: CBPeripheral?,
    withSensorManager sensorManager: BBLSensorManager!,
    withfromJSONDictionary dictionary: [String:AnyObject]) -> BBLSensor {
      
      //TODO: Parse JSON and initialize values
      let uuidFromJSON = "someUniqueIdentifier"
      let capSenseThreshFromJSON = 30
      let delayInSecondsFromJSON = 3
      return BBLSensor.init(withPeripheral: peripheral,
        withSensorManager: sensorManager,
        withUUID: uuidFromJSON,
        withCapSenseThreshold: capSenseThreshFromJSON,
        withDelayInSeconds: delayInSecondsFromJSON,
        withDelegate: nil)
      
  }
  
  // Class initializer for instantating a sensor from connection.
  class func  sensorWith(peripheral: CBPeripheral!,
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
    parentsCount++
  }
  
  internal func decrementParentsCount() {
    parentsCount--
    if parentsCount == 0 {
      deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
        if let error = error {
          if let delegate = self.delegate as? NSObject where delegate.respondsToSelector("sensor:didDidFailToDeleteSensorWithErrorMessage:") {
            (delegate as! BBLSensorDelegate).sensor(self, didDidFailToDeleteSensorWithErrorMessage: error.localizedDescription)
          }
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
      if (sensorManager.state == .PoweredOff) {
        stateMachine.state = .Disconnected
      }
      sensorManager.disconnectSensor(self)
    }
  }
  
  internal func onDidConnect() {
    stateMachine.state = .Deactivated
  }
  
  internal func onDidDisconnect() {
    stateMachine.state = .Disconnected
  }
  
  private func alertUserWithMessage(message: String, andTitle title:String) {
    let notification = UILocalNotification()
    notification.alertAction = nil
    notification.alertTitle = title
    notification.alertBody = name! + message
    notification.fireDate = NSDate(timeIntervalSinceNow: 0)
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.repeatInterval = NSCalendarUnit.Second
    notification.soundName = "default" //required for vibration?
    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
  internal func updateToDisconnectedState() {
    connectedParent = nil
  }
  
  // MARK: Access
  
  internal func rebaseline() {
    if let rebaselineCharacteristic = rebaselineCharacteristic {
      peripheral?.writeValue(BBLSensorInfo.kRebaselineValue!, forCharacteristic: rebaselineCharacteristic, type: CBCharacteristicWriteType.WithResponse)
    }
  }
  
}

// MARK: CBPeripheralDelegate

extension BBLSensor: CBPeripheralDelegate {
  
  internal func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    
    let uuid = characteristic.UUID
    
    if uuid == BBLSensorInfo.kCapSenseValueCharacteristicUUID {
      var value = 0
      characteristic.value?.getBytes(&value, length: sizeof(Int))
      capSenseValue = value
      
      if let delegate = delegate as? NSObject where delegate.respondsToSelector("sensor:didUpdateSensorValue:") {
        (delegate as! BBLSensorDelegate).sensor(self, didUpdateSensorValue: capSenseValue!)
      }
      
      switch (stateMachine.state as BBLSensorState) {
      case .Deactivated:
        if hasBaby { stateMachine.state = .WaitingToBeActivated }
      case .WaitingToBeActivated:
        if !hasBaby {
          stateMachine.state = .Deactivated
          stopCountdownTimer(countdownTimer)
        }
      case .Activated:
        if !hasBaby { stateMachine.state = .WaitingToBeDeactivated }
      case .WaitingToBeDeactivated:
        if hasBaby {
          stateMachine.state = .Activated
          stopCountdownTimer(countdownTimer)
        }
      default:
        // Do nothing
        break
      }
    }
  }
  
  internal func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
    rssi = RSSI
  }
  
  internal func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    peripheral.discoverCharacteristics([BBLSensorInfo.kCapSenseValueCharacteristicUUID, BBLSensorInfo.kCapSenseValueCharacteristicUUID], forService: (peripheral.services?.first)!)
  }
  
  internal func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.UUID == BBLSensorInfo.kCapSenseValueCharacteristicUUID {
          peripheral.setNotifyValue(true, forCharacteristic: characteristic)
          rebaselineCharacteristic = characteristic
        }
      }
    }
    
  }
  
  internal func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    if let error = error {
      print(error.localizedDescription + " Failed to write to characteristic: " + characteristic.description)
    }
  }
  
}

// MARK: BBLStateMachineDelegate

extension BBLSensor:BBLStateMachineDelegateProtocol{
  typealias StateType = BBLSensorState
  
  internal func shouldTransitionFrom(from:StateType, to:StateType)->Bool{
    switch (from, to){
    case (.Disconnected, .Deactivated),
    (.Deactivated, .Disconnected),
    (.Deactivated, .WaitingToBeActivated),
    (.WaitingToBeActivated, .Deactivated),
    (.WaitingToBeActivated, .Activated),
    (.Activated, .WaitingToBeDeactivated),
    (.WaitingToBeDeactivated, .Activated),
    (.WaitingToBeDeactivated, .Deactivated):
      return true
    case (_, .Disconnected):
      return true
    default:
      return false
    }
  }
  
  internal func didTransitionFrom(from:StateType, to:StateType){
    switch (from, to){
      
    case (.Disconnected, .Deactivated):
      connectedParent = BBLParent.loggedInParent()
      peripheral!.discoverServices([BBLSensorInfo.kSensorServiceUUID])
      peripheral!.delegate = self
      // TODO: Start timer to poll for RSSI on connection.  Stop timer on disconnect.
      peripheral?.readRSSI()
      
    case (.Deactivated, .WaitingToBeActivated):
      startCountdownForTimeInSeconds(delayInSeconds)
      
    case (.Activated, .WaitingToBeDeactivated):
      startCountdownForTimeInSeconds(delayInSeconds)
      
    case (.WaitingToBeActivated, .Activated):
      alertUserWithMessage(BBLSensorInfo.Alerts.sensorActivatedAlertMessage, andTitle: BBLSensorInfo.Alerts.sensorActivatedAlertTitle)
      
    case (.WaitingToBeDeactivated, .Deactivated):
      alertUserWithMessage(BBLSensorInfo.Alerts.sensorDeactivatedAlertMessage, andTitle: BBLSensorInfo.Alerts.sensorDeactivatedAlertTitle)
      
    case (.Activated, .Disconnected):
      alertUserWithMessage(BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertMessage, andTitle: BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertTitle)
      afterDisconnection()
      
    case (.WaitingToBeDeactivated, .Disconnected):
      alertUserWithMessage(BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertMessage, andTitle: BBLSensorInfo.Alerts.babyInSeatAndOutOfRangeAlertTitle)
      afterDisconnection()
      
    case (_, .Disconnected):
      afterDisconnection()
      
      
    default:
      break
    }
    
    delegate?.sensor(self, didChangeState: to)
    
  }
  
  private func afterDisconnection(){
    stopCountdownTimer(countdownTimer)
    connectedParent = nil
    saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      }
    }
    //TODO: Check backend and alert user.
  }
  
}

// MARK: Timer

extension BBLSensor {
  private func startCountdownForTimeInSeconds(seconds: Int) {
    countdownTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(seconds), target: self, selector: "countdownEnded:", userInfo: nil, repeats: false)
  }
  
  internal func countdownEnded(timer: NSTimer) {
    switch stateMachine.state {
    case .WaitingToBeActivated:
      stateMachine.state = .Activated
    case .WaitingToBeDeactivated:
      stateMachine.state = .Deactivated
    default:
      print("Sensor countdown ended from a state that is not WaitingToBeActivated or WaitingToBeDeactivated.")
    }
    
    stopCountdownTimer(timer)
  }
  
  private func stopCountdownTimer(timer: NSTimer?) {
    if let timer = timer {
      timer.invalidate()
    }
  }
}