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
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var currentSession: BBLSession?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupLocalNotificationsForApplication(application)
    setupNotificationsForObject(self)
    Fabric.with([Crashlytics.self, Digits.self])
    setupParse()
    
    let loginViewController = BBLLoginViewController()
    loginViewController.delegate = self
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window!.rootViewController = loginViewController
    window!.makeKeyAndVisible()
    
    return true
  }
  
  private func setupLocalNotificationsForApplication(application: UIApplication) {
    let notificationTypes: UIUserNotificationType = [.Badge, .Sound, .Alert]
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: notificationTypes, categories: nil))
  }
  
  private func setupNotificationsForObject(object: NSObject) {
    NSNotificationCenter.defaultCenter().addObserver(object, selector: "parentDidLogout", name: kParentDidLogoutNotification, object: nil)
  }
  
  internal func parentDidLogout() {
    updateConnectionStatusForParent((currentSession?.parent)!)
    let loginViewController = BBLLoginViewController()
    loginViewController.delegate = self
    window?.rootViewController = loginViewController
  }
  
  private func updateConnectionStatusForParent(parent: BBLParent) {
        let query = PFQuery(className: "BabySensor")
        query.whereKey("connectedParent", equalTo: parent)
        query.findObjectsInBackgroundWithBlock {(sensors:[PFObject]?, error:NSError?) -> Void in
    
          if let error = error {
            print(error.localizedDescription)
            return
          }
          
          if let sensors = sensors as? [BBLSensor]{
            for sensor in sensors {
              sensor.updateToDisconnectedState()
            }
            BBLSensor.saveAllInBackground(sensors, block: { (success: Bool, error: NSError?) -> Void in
              BBLParent.logOut()
              self.currentSession = nil
            })
          } else {
            BBLParent.logOut()
            self.currentSession = nil
          }
    }
  }
  
  private func setupParse() {
    BBLParent.registerSubclass()
    BBLSensor.registerSubclass()
    Parse.setApplicationId("HHgxoEaLenjAwxhAqOGziC9SkHaIi4oeTibRFczc", clientKey: "fK00wH0VssppmFZywgP6pRQQUhvsqLpGG6HYFu5u")
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
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}

extension AppDelegate: PFLogInViewControllerDelegate {
  
  internal func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
    //
  }
  
  internal func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    let loggedInParent = BBLParent.loggedInParent()
    
    BBLSensor.fetchAllInBackground(loggedInParent.sensors) { (result: [AnyObject]?, error: NSError?) -> Void in
      loggedInParent.syncSensors()
      
      self.currentSession = BBLSession(withParent: loggedInParent,
                                withSensorManager: BBLSensorManager(withCentralManager: CBCentralManager(),
                                                                          withDelegate: nil,
                                                                    withProfileSensors: loggedInParent.profileSensors))
      self.setupViewsAfterLoginWithSession(self.currentSession!)
    }
    
    
  }
  
  internal func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
    return true
  }
  
  internal func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
    //
  }
  
  private func setupViewsAfterLoginWithSession(session: BBLSession) {
    let mainTabBarController = UITabBarController()
    let sensorsViewController = BBLMySensorsViewController()
    sensorsViewController.loggedInParent = session.parent
    let connectionViewController = BBLConnectionViewController()
    connectionViewController.sensorManager = session.sensorManager
    
    let tabBarViewControllers = [sensorsViewController,
                                connectionViewController]
    var navigationControllers = [UINavigationController]()
    
    for vc in tabBarViewControllers {
      navigationControllers.append(UINavigationController(rootViewController: vc))
    }
    
    mainTabBarController.viewControllers = navigationControllers
    window?.rootViewController = mainTabBarController
  }
  
}