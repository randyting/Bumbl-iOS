//
//  BBLAppDelegate.swift
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
internal final class BBLAppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var currentSession: BBLSession?
  
// MARK: Lifecycle
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setupLocalNotificationsForApplication(application)
    setupNotificationsForObject(self)
    setupFabric()
    setupParse()
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    setupViewsForWindow(window!)
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
  }
  
  func applicationWillTerminate(application: UIApplication) {
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
// MARK: Setup
  
  private func setupFabric() {
    Fabric.sharedSDK().debug = true
    Fabric.with([Crashlytics.self, Digits.self])
  }
  
  private func setupLocalNotificationsForApplication(application: UIApplication) {
    let notificationTypes: UIUserNotificationType = [.Badge, .Sound, .Alert]
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: notificationTypes, categories: nil))
  }
  
  private func setupNotificationsForObject(object: NSObject) {
    NSNotificationCenter.defaultCenter().addObserver(object, selector: "parentDidLogout", name: BBLNotifications.kParentDidLogoutNotification, object: nil)
  }
  
  private func setupParse() {
    BBLParent.registerSubclass()
    BBLSensor.registerSubclass()
    Parse.setApplicationId("HHgxoEaLenjAwxhAqOGziC9SkHaIi4oeTibRFczc", clientKey: "fK00wH0VssppmFZywgP6pRQQUhvsqLpGG6HYFu5u")
  }
  
  private func setupBlankLoginViewController(loginViewController: BBLLoginViewController, inWindow window: UIWindow){
    loginViewController.delegate = self
    window.rootViewController = loginViewController
  }
  
  private func setupViewsForWindow(window: UIWindow) {
    if let loggedInParent = BBLParent.loggedInParent() {
      setupBlankLoginViewController(BBLLoginViewController(), inWindow: window) // TODO: (RT) Replace this with a blank launch screen.
      loginWithParent(loggedInParent)
    } else {
      setupBlankLoginViewController(BBLLoginViewController(), inWindow: window)
    }
    
    window.makeKeyAndVisible()
  }
  
// MARK: Logout
  
  internal func parentDidLogout() {
    disconnectAllSensorsAndStopScanningForSession(currentSession)
    setupBlankLoginViewController(BBLLoginViewController(), inWindow: window!)
  }
  
  private func disconnectAllSensorsAndStopScanningForSession(session: BBLSession!) {
    session.sensorManager.stopScanningForSensors()
    session.sensorManager.disconnectAllProfileSensorsWithCompletion { () -> () in
      self.logoutOfSession(self.currentSession)
    }
  }
  
  private func logoutOfSession(var session: BBLSession?) {
    BBLParent.logOut()
    session = nil
  }
}

// MARK: PFLogInViewControllerDelegate
// MARK: Login
  
  extension BBLAppDelegate: PFLogInViewControllerDelegate {
    
    internal func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
      //
    }
    
    internal func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
      loginWithParent(BBLParent.loggedInParent())
      setCrashlyticsParent(BBLParent.loggedInParent()!)
    }
    
    internal func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
      return true
    }
    
    internal func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
      //
    }
    
    private func setCrashlyticsParent(parent: BBLParent) {
      Crashlytics.sharedInstance().setUserIdentifier(parent.objectId)
      Crashlytics.sharedInstance().setUserName(parent.username)
      Crashlytics.sharedInstance().setUserEmail(parent.email)
    }
    
    private func loginWithParent(parent: BBLParent!) {
      BBLSensor.fetchAllInBackground(parent.sensors) { (result: [AnyObject]?, error: NSError?) -> Void in
        parent.syncSensors()
        
        self.currentSession = BBLSession(withParent: parent,
          withSensorManager: BBLSensorManager(withCentralManager: CBCentralManager(),
            withProfileSensors: parent.profileSensors))
        self.window?.rootViewController = self.rootViewControllerFromSession(self.currentSession!)
      }
    }
    
    private func rootViewControllerFromSession(session: BBLSession!) -> UITabBarController {
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
      
      sensorsViewController.BBLsetupIcon(BBLViewControllerInfo.BBLMySensorsViewController.tabBarIcon, andTitle: BBLViewControllerInfo.BBLMySensorsViewController.title)
      connectionViewController.BBLsetupIcon(BBLViewControllerInfo.BBLConnectionViewController.tabBarIcon, andTitle: BBLViewControllerInfo.BBLConnectionViewController.title)
      
      mainTabBarController.viewControllers = navigationControllers
      return mainTabBarController
    }
    
}