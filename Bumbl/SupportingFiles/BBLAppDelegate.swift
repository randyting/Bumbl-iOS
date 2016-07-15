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
    NSNotificationCenter.defaultCenter().addObserver(object, selector: #selector(BBLAppDelegate.parentDidLogout), name: BBLNotifications.kParentDidLogoutNotification, object: nil)
  }
  
  private func setupParse() {
    BBLParent.registerSubclass()
    BBLSensor.registerSubclass()
    Parse.setApplicationId("HHgxoEaLenjAwxhAqOGziC9SkHaIi4oeTibRFczc", clientKey: "fK00wH0VssppmFZywgP6pRQQUhvsqLpGG6HYFu5u")
  }
  
  private func setupSignInPickerVC(signInPickerVC: BBLSignInPickerVC, inWindow: UIWindow) {
    window?.rootViewController = signInPickerVC
  }
  
  private func setupSplashScreenFromStoryboard(storyboard: UIStoryboard, inWindow: UIWindow) {
    let splashScreenVC = storyboard.instantiateViewControllerWithIdentifier("launchScreen")
    window?.rootViewController = splashScreenVC
  }

  private func onboardingCompleteFromDefaults(defaults: NSUserDefaults) -> Bool {
    return defaults.boolForKey(BBLAppState.kDefaultsOnboardingCompleteKey)
  }
  
  private func setupOnboardingFlowInWindow(window: UIWindow) {
    let rootVC = UINavigationController(rootViewController: BBLIntroViewController())
    rootVC.navigationBarHidden = true
    window.rootViewController = rootVC
  }
  
  private func setupViewsForWindow(window: UIWindow) {
    
    if let loggedInParent = BBLParent.loggedInParent() {
      setupSplashScreenFromStoryboard(UIStoryboard(name: "LaunchScreen", bundle: nil), inWindow: window)
      loginWithParent(loggedInParent)
    } else if (onboardingCompleteFromDefaults(NSUserDefaults.standardUserDefaults()) == false) {
      setupOnboardingFlowInWindow(window)
    } else {
      setupSignInPickerVC(BBLSignInPickerVC(), inWindow: window)
    }
    
    window.makeKeyAndVisible()
  }
  
// MARK: Logout
  
  internal func parentDidLogout() {
    disconnectAllSensorsAndStopScanningForSession(currentSession)
    setupSignInPickerVC(BBLSignInPickerVC(), inWindow: window!)
  }
  
  private func disconnectAllSensorsAndStopScanningForSession(session: BBLSession!) {
    session.sensorManager.stopScanningForSensors()
    session.sensorManager.disconnectAllProfileSensorsWithCompletion { () -> () in
      self.logoutOfSession(&self.currentSession)
    }
  }
  
  private func logoutOfSession(inout session: BBLSession?) {
    
    BBLParent.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("logout complete")
        session = nil
      }
    }
    
  }

}

// MARK: PFLogInViewControllerDelegate
// MARK: Login
  
  extension BBLAppDelegate: BBLLoginViewControllerDelegate {
    
    internal func logInViewController(logInController: BBLLoginViewController, didFailToLogInWithError error: NSError?) {
      //
    }
    
    internal func logInViewController(logInController: BBLLoginViewController, didLogInUser user: PFUser) {
      loginWithParent(BBLParent.loggedInParent())
      setCrashlyticsParent(BBLParent.loggedInParent()!)
    }
    
    internal func logInViewController(logInController: BBLLoginViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
      return true
    }
    
    private func setCrashlyticsParent(parent: BBLParent) {
      Crashlytics.sharedInstance().setUserIdentifier(parent.objectId)
      Crashlytics.sharedInstance().setUserName(parent.username)
      Crashlytics.sharedInstance().setUserEmail(parent.email)
    }
    
    private func loginWithParent(parent: BBLParent!) {
      BBLSensor.fetchAllInBackground(parent.sensors) { (result: [AnyObject]?, error: NSError?) -> Void in
        if let sensors = result as? [BBLSensor] {
          for sensor in sensors {
            try! sensor.connectedParent?.fetchIfNeeded()
            sensor.stateMachine = BBLStateMachine(initialState: .Disconnected, delegate: sensor)
          }
        }
        
        parent.syncSensors()
        
        self.currentSession = BBLSession(withParent: parent,
                                         withSensorManager: BBLSensorManager(withCentralManager: CBCentralManager(),
                                                                              withProfileSensors: parent.profileSensors))
        self.window?.rootViewController = self.rootViewControllerFromSession(self.currentSession!)
      }
    }
    
    private func rootViewControllerFromSession(session: BBLSession!) -> UITabBarController {
      let mainTabBarController = UITabBarController()
      setupAppearanceForTabBar(mainTabBarController.tabBar)
      
      let sensorsViewController = BBLMySensorsViewController()
      sensorsViewController.loggedInParent = session.parent
      sensorsViewController.sensorManager = session.sensorManager
      
      let emergencyContactsVC = BBLEmergencyContactsViewController()
      
      let tabBarViewControllers = [sensorsViewController,
        emergencyContactsVC]
      var navigationControllers = [UINavigationController]()
      
      for vc in tabBarViewControllers {
        navigationControllers.append(UINavigationController(rootViewController: vc))
      }
      
      sensorsViewController.BBLsetupIcon(BBLViewControllerInfo.BBLMySensorsViewController.tabBarIcon, andTitle: BBLViewControllerInfo.BBLMySensorsViewController.title)
      emergencyContactsVC.BBLsetupIcon(BBLViewControllerInfo.BBLEmergencyContactsViewController.tabBarIcon, andTitle: BBLViewControllerInfo.BBLEmergencyContactsViewController.title)
      
      mainTabBarController.viewControllers = navigationControllers
      return mainTabBarController
    }
    
    private func setupAppearanceForTabBar(tabBar: UITabBar) {
      tabBar.barTintColor = UIColor.whiteColor()
      tabBar.addTopBorder(withColor: UIColor.BBLDarkGrayColor(), withThickness: 0.5)
      tabBar.tintColor = UIColor.BBLTabBarSelectedIconColor()
    }
    
}