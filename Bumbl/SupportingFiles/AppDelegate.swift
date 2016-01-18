//
//  AppDelegate.swift
//  Bumbl
//
//  Created by Randy Ting on 1/9/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import DigitsKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  internal var sensorManager: BBLSensorManager?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let notificationTypes: UIUserNotificationType = [.Badge, .Sound, .Alert]
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: notificationTypes, categories: nil))
    
    Fabric.with([Crashlytics.self, Digits.self])

    sensorManager = BBLSensorManager(withCentralManager: CBCentralManager(),
                            withDelegate: self,
                      withProfileSensors: nil)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      // Must wait for sensorManager to be in powered on state before scanning
      self.sensorManager?.scanForSensors()
    }

    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

extension AppDelegate: BBLSensorManagerDelegate {
  
  func sensorManager(sensorManager: BBLSensorManager, didConnectSensor sensor: BBLSensor) {
    print("Did connect to sensor " + sensor.description)
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didAttemptToScanWhileBluetoothRadioIsOff isBluetoothRadioOff: Bool) {
    print("Did attempt to scan while BT radio is off.")
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didDisconnectSensor sensor: BBLSensor) {
    print("Did disconnect sensor " + sensor.description)
  }
  
  func sensorManager(sensorManager: BBLSensorManager, didDiscoverSensor sensor: BBLSensor) {
    print("Did discover sensor " + sensor.description)
    sensor.connect()  
  }
}