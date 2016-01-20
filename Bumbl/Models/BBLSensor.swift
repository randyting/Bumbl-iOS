//
//  BBLSensor.swift
//  Bumbl
//
//  Created by Randy Ting on 1/12/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BBLSensorDelegate {
  optional func sensor(sensor: BBLSensor, didUpdateRSSI rssi: NSNumber)
  optional func sensor(sensor: BBLSensor, didConnect connected: Bool)
  optional func sensor(sensor: BBLSensor, didDisconnect disconnnected: Bool)
}

class BBLSensor: PFObject, PFSubclassing {
  
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
  internal weak var delegate: BBLSensorDelegate?
  internal var rssi: NSNumber?
  internal var peripheral:CBPeripheral?
  @NSManaged private(set) var uuid: String?
  private(set) var hasBaby:Bool? {
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
  private weak var sensorManager: BBLSensorManager!
  private var capSenseValue:Int?
  @NSManaged private var capSenseThreshold:Int
  
// MARK: Initialization
  
  // Designated initializer
  internal convenience init(withPeripheral peripheral: CBPeripheral?,
          withSensorManager sensorManager: BBLSensorManager!,
                            withUUID uuid: String!,
  withCapSenseThreshold capSenseThreshold: Int,
                    withDelegate delegate: BBLSensorDelegate?) {
    self.init()
    self.peripheral = peripheral
    self.sensorManager = sensorManager
    self.uuid = uuid
    self.capSenseThreshold = capSenseThreshold
    self.delegate = delegate
                      
    let query = PFQuery(className: "BabySensor")
    query.whereKey("uuid", equalTo: uuid)
    query.findObjectsInBackgroundWithBlock { (sensors:[PFObject]?, error:NSError?) -> Void in
      
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      if let storedSensor = sensors?.first as? BBLSensor {
        self.objectId = storedSensor.objectId
        self.uuid = storedSensor.uuid
        self.capSenseThreshold = storedSensor.capSenseThreshold
      } else {
        self.saveInBackground()
      }
    }
    
    peripheral?.delegate = self
  }
  
// MARK: Class Methods
  
  // Class initializer for instantiating an existing peripheral loaded from the server or persistent storage.
  class func  sensorWith(peripheral: CBPeripheral?,
    withSensorManager sensorManager: BBLSensorManager!,
    withfromJSONDictionary dictionary: [String:AnyObject]) -> BBLSensor {
      
      //TODO: Parse JSON and initialize values
      let uuidFromJSON = "someUniqueIdentifier"
      let capSenseThreshFromJSON = 30
      return BBLSensor.init(withPeripheral: peripheral,
        withSensorManager: sensorManager,
        withUUID: uuidFromJSON,
        withCapSenseThreshold: capSenseThreshFromJSON,
        withDelegate: nil)
      
  }
  
  // Class initializer for instantating a sensor from connection.
  class func  sensorWith(peripheral: CBPeripheral!,
    withSensorManager sensorManager: BBLSensorManager!) -> BBLSensor {
      
      return BBLSensor.init(withPeripheral: peripheral,
        withSensorManager: sensorManager,
        withUUID: peripheral.identifier.UUIDString,
        withCapSenseThreshold: kDefaultCapSenseThreshold,
        withDelegate: nil)
      
  }
  
// MARK: Access
  internal func addToProfile() {
    // TODO: Add sensor to current logged in parent's profile.
  }
  
  internal func removeFromProfile() {
    // TODO: Remove sensor from current logged in parent's profile.
  }

// MARK: Connection
  internal func connect() {
    if let _ = self.peripheral {
      sensorManager.connectToSensor(self)
    }
  }
  
  internal func disconnect() {
    if let _ = self.peripheral {
      sensorManager.disconnectSensor(self)
    }
  }
  
  internal func onDidConnect() {
    peripheral!.discoverServices([kSensorServiceUUID])
    // TODO: Start timer to poll for RSSI on connection.  Stop timer on disconnect.
    peripheral?.readRSSI()
    delegate?.sensor?(self, didConnect: true)
  }
  
  internal func onDidDisconnect() {
    //TODO: Check backend and alert user.
    //TODO: Update UI
    alertUserWithMessage("This is a message that you disconnected.")
    delegate?.sensor?(self, didDisconnect: true)
  }
  
  private func alertUserWithMessage(message: String) {
    let notification = UILocalNotification()
    notification.alertAction = nil
    notification.alertTitle = message
    notification.alertBody = "Baby Dead"
    notification.fireDate = NSDate(timeIntervalSinceNow: 0)
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.repeatInterval = NSCalendarUnit.Second
    notification.soundName = "default" //required for vibration?
    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }
  
}

// MARK: CBPeripheralDelegate

extension BBLSensor: CBPeripheralDelegate {
  
  internal func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

    let uuid = characteristic.UUID
    
    if uuid == kCapSenseValueCharacteristicUUID {
      var value = 0
      characteristic.value?.getBytes(&value, length: sizeof(Int))
      capSenseValue = value
    }
  }
  
  func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
    rssi = RSSI
  }
  
  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    peripheral.discoverCharacteristics([kCapSenseValueCharacteristicUUID], forService: (peripheral.services?.first)!)
  }
  
  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    peripheral.setNotifyValue(true, forCharacteristic: (service.characteristics?.first)!)
  }
  
  
}

