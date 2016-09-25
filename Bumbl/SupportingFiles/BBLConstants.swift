//
//  BBLConstants.swift
//  Bumbl
//
//  Created by Randy Ting on 1/17/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: Bluetooth
internal struct BBLBluetoothInfo {
  
    static let kRestorationIdentifier = "com.bumblbaby.cbCentralRestorationIdentifier"
}


// MARK: Avatars

internal struct BBLAvatarsInfo {
  
  enum BBLAvatarType: Int {
    
    case rabbit, pig, cat, chick, dog, monkey, count
    
    internal func color() -> UIColor {
      switch self {
      case .rabbit:
        return UIColor.BBLAvatarBlueColor()
      case .pig:
        return UIColor.BBLAvatarGreenColor()
      case .cat:
        return UIColor.BBLAvatarYellowColor()
      case .chick:
        return UIColor.BBLAvatarPurpleColor()
      case .dog:
        return UIColor.BBLAvatarPinkColor()
      case .monkey:
        return UIColor.BBLAvatarOrangeColor()
      default:
        fatalError("Unexpected BBLAvatarType index.")
      }
    }
    
    internal func stringName() -> String {
      switch self {
      case .rabbit:
        return "Rabbit"
      case .pig:
        return "Pig"
      case .cat:
        return "Cat"
      case .chick:
        return "Chick"
      case .dog:
        return "Dog"
      case .monkey:
        return "Monkey"
      default:
        fatalError("Unexpected BBLAvatarType index.")
      }
    }
    
    
    internal func image() -> UIImage {
      switch self {
      case .rabbit:
        return UIImage(named: "BBLRabbitAvatar")!
      case .pig:
        return UIImage(named: "BBLPigAvatar")!
      case .cat:
        return UIImage(named: "BBLCatAvatar")!
      case .chick:
        return UIImage(named: "BBLChickAvatar")!
      case .dog:
        return UIImage(named: "BBLDogAvatar")!
      case .monkey:
        return UIImage(named: "BBLMonkeyAvatar")!
      default:
        fatalError("Unexpected BBLAvatarType index.")
      }
    }
    
    internal func isEqual(_ rhs: BBLAvatarType) -> Bool {
      if self.rawValue == rhs.rawValue {
        return true
      } else {
        return false
      }
    }
  }
  
}


// MARK: Navigation Bar

internal struct BBLNavigationBarInfo {
  
  static let kMenuButtonIconName = "BBLMenuButton"
  static let kDismissButtonIconName = "BBLDismissIcon"
  
}

// MARK: View Controllers
internal struct BBLViewControllerInfo {
  struct BBLDebugMySensorsViewController {
    static let title = "Debug My Sensors"
    fileprivate static let kHomeTabBarIconName = "BBLHomeTabBarIcon"
    static let tabBarIcon:UIImage? = UIImage(named: BBLViewControllerInfo.BBLDebugMySensorsViewController.kHomeTabBarIconName)
  }
  
  struct BBLDebugConnectionViewController {
    static let title = "Debug Connect"
    static let tabBarIcon:UIImage? = nil
  }
  
  struct BBLMySensorsViewController {
    static let title = "Dashboard"
    fileprivate static let kHomeTabBarIconName = "BBLHomeTabBarIcon"
    static let tabBarIcon:UIImage? = UIImage(named: BBLViewControllerInfo.BBLMySensorsViewController.kHomeTabBarIconName)
  }
  
  struct BBLEmergencyContactsViewController {
    static let title = "Contacts"
    fileprivate static let kEmergencyContactsTabBarIconName = "BBLEmergencyContactsTabBarIcon"
    static let tabBarIcon:UIImage? = UIImage(named: BBLViewControllerInfo.BBLEmergencyContactsViewController.kEmergencyContactsTabBarIconName)
  }
  
}

// MARK: App State
internal struct BBLAppState {
  
  /// Key in NSUserdefaults for determining whether onboarding flow should be presented.
  static let kDefaultsOnboardingCompleteKey = "com.bumbl.kDefaultsOnboardingCompletKey"
  
}

// MARK: Sensor Info
internal struct BBLSensorInfo {
  
  /// BLE service UUID that all sensors advertise.  The characteristics we use must be under this service.
  static let kSensorServiceUUID = CBUUID.init(string: "0003CAB5-0000-1000-8000-00805F9B0131")
  
  /// BLE characteristic UUID for cap sense measurement.
  static let kCapSenseValueCharacteristicUUID = CBUUID.init(string: "0003CAA1-0000-1000-8000-00805F9B0131")
  
  /// Value to write to rebaseline characteristic to rebaseline
  static let kRebaselineValue = "rebaseline".data(using: String.Encoding.utf8)
  
  /// Cap sense threshold for determining if baby is on sensor or not.
  static let kDefaultCapSenseThreshold: UInt = 50
  
  /// Default delay for transition between activated and deactivated states
  static let kDefaultDelayInSeconds = 3
  
  /// Alerts that will be triggered when the app is backgrounded.
  struct Alerts {
    // When the baby is in the carseat and the sensor disconnects, but another parent does not connect to the sensor.
    static let babyInSeatAndOutOfRangeAlertTitle = "Get your baby!"
    static let babyInSeatAndOutOfRangeAlertMessage = " is still in your car!"
    
    // When the baby is in the carseat and the sensor disconnects, but another parent connects to the sensor.
    static let babyInSeatWithOtherParentAlertTitle = "Don't worry."
    static let babyInSeatWithOtherParentAlertMessage = " is safe with another caretaker."
    
    // When the sensor disconnects without a baby.
    static let sensorActivatedAlertTitle = "Baby placed in seat."
    static let sensorActivatedAlertMessage = "'s Sensor Activated."
    
    // When the sensor connects.
    static let sensorDeactivatedAlertTitle = "Baby removed from seat"
    static let sensorDeactivatedAlertMessage = "'s Sensor Deactivated."
    
  }
}

// MARK:  Notifications
internal struct BBLNotifications {  
  /// On parent logout
  static let kParentDidLogoutNotification = "com.randy.ParentDidLogoutNotification"
}


