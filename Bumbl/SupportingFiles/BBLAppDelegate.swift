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
import CoreBluetooth
import UserNotifications


@UIApplicationMain
internal final class BBLAppDelegate: UIResponder, UIApplicationDelegate {
  
  
  // MARK: Constants
  
  fileprivate enum BBLAppDelegateConstants {
    static let kParseInfoPlistPath = "ParseService-Info"
  }
  
  // MARK: Public Properties
  
  var window: UIWindow?
  var currentSession: BBLSession?
  
  // MARK: Lifecycle
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    setupLocalNotificationsForApplication(application)
    setupNotificationsForObject(self)
    setupFabric()
    setupParse()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    setupViewsForWindow(window!)
    
    return true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Setup
  
  fileprivate func setupFabric() {
    Fabric.sharedSDK().debug = true
    Fabric.with([Crashlytics.self])
  }
  
  fileprivate func setupLocalNotificationsForApplication(_ application: UIApplication) {
    
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
      // TODO: Enable or disable features based on authorization.
    }
    center.delegate = self
    
    
  }
  
  fileprivate func setupNotificationsForObject(_ object: NSObject) {
    NotificationCenter.default.addObserver(object, selector: #selector(BBLAppDelegate.parentDidLogout), name: NSNotification.Name(rawValue: BBLNotifications.kParentDidLogoutNotification), object: nil)
  }
  
  fileprivate func parseConfig(fromInfoPlistPath path: String) -> ParseClientConfiguration {
    
    guard let infoPlistPath = Bundle.main.path(forResource: path, ofType: "plist") else {
      fatalError("Failed to fetch path for ParseService-Info.plist.")
    }
    
    guard let parseConfigDict = NSDictionary(contentsOfFile: infoPlistPath) as? [String:Any] else {
      fatalError("Failed to read ParseService-Info.plist.")
    }
    
    
    return ParseClientConfiguration { (ParseMutableClientConfiguration) in
      
      ParseMutableClientConfiguration.applicationId = (parseConfigDict["PARSE_APP_ID"] as! String)
      ParseMutableClientConfiguration.clientKey = (parseConfigDict["PARSE_CLIENT_KEY"] as! String)
      ParseMutableClientConfiguration.server = (parseConfigDict["PARSE_DATABASE_URL"] as! String)
    }

  }
  
  fileprivate func setupParse() {
    BBLParent.registerSubclass()
    BBLSensor.registerSubclass()
    BBLContact.registerSubclass()

    let parseConfiguration = parseConfig(fromInfoPlistPath: BBLAppDelegateConstants.kParseInfoPlistPath)
    Parse.initialize(with: parseConfiguration)
  }
  
  fileprivate func setupSignInPickerVC(_ signInPickerVC: BBLSignInPickerVC, inWindow: UIWindow) {
     window?.setRootViewController(newRootViewController:UINavigationController(rootViewController: signInPickerVC))
  }
  
  fileprivate func setupSplashScreenFromStoryboard(_ storyboard: UIStoryboard, inWindow: UIWindow) {
    let splashScreenVC = storyboard.instantiateViewController(withIdentifier: "launchScreen")
     window?.setRootViewController(newRootViewController:splashScreenVC)
  }
  
  fileprivate func onboardingCompleteFromDefaults(_ defaults: UserDefaults) -> Bool {
    return defaults.bool(forKey: BBLAppState.kDefaultsOnboardingCompleteKey)
  }
  
  fileprivate func setupOnboardingFlowInWindow(_ window: UIWindow) {
    let rootVC = UINavigationController(rootViewController: BBLIntroViewController())
    rootVC.isNavigationBarHidden = true
//    window.rootViewController = rootVC
    window.setRootViewController(newRootViewController: rootVC)
  }
  
  fileprivate func setupViewsForWindow(_ window: UIWindow) {
    
    if let loggedInParent = BBLParent.loggedInParent() {
      setupSplashScreenFromStoryboard(UIStoryboard(name: "LaunchScreen", bundle: nil), inWindow: window)
      loginWithParent(loggedInParent)
    } else if (onboardingCompleteFromDefaults(UserDefaults.standard) == false) {
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
  
  fileprivate func disconnectAllSensorsAndStopScanningForSession(_ session: BBLSession!) {
    session.sensorManager.stopScanningForSensors()
    session.sensorManager.disconnectAllProfileSensorsWithCompletion { () -> () in
      self.logoutOfSession(&self.currentSession)
    }
  }
  
  fileprivate func logoutOfSession(_ session: inout BBLSession?) {
    print("Session is first \(session)")
    BBLParent.logOutInBackground { [weak session] (error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("logout complete")
        print("Session is now \(session)")
        session = nil
      }
    }
    
  }
  
}

// MARK: UNUserNotificationCenterDelegate

extension BBLAppDelegate: UNUserNotificationCenterDelegate {
  
  @objc(userNotificationCenter:willPresentNotification:withCompletionHandler:) internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge,.sound])
  }
  
}

// MARK: PFLogInViewControllerDelegate
// MARK: Login

extension BBLAppDelegate: BBLLoginViewControllerDelegate {
  
  internal func logInViewController(_ logInController: BBLLoginViewController, didFailToLogInWithError error: Error?) {
    //
  }
  
  internal func logInViewController(_ logInController: BBLLoginViewController, didLogInUser user: PFUser) {
    loginWithParent(BBLParent.loggedInParent())
    setCrashlyticsParent(BBLParent.loggedInParent()!)
  }
  
  internal func logInViewController(_ logInController: BBLLoginViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
    return true
  }
  
  fileprivate func setCrashlyticsParent(_ parent: BBLParent) {
    Crashlytics.sharedInstance().setUserIdentifier(parent.objectId)
    Crashlytics.sharedInstance().setUserName(parent.username)
    Crashlytics.sharedInstance().setUserEmail(parent.email)
  }
  
  fileprivate func loginWithParent(_ parent: BBLParent!) {
    
    BBLSensor.fetchAll(inBackground: parent.sensors) { (result: [Any]?, error: Error?) -> Void in
      if let sensors = result as? [BBLSensor] {
        for sensor in sensors {
          try! sensor.connectedParent?.fetchIfNeeded()
          sensor.stateMachine = BBLStateMachine(initialState: .disconnected, delegate: sensor)
        }
      }
      
      parent.syncSensors()
      
      let sensorManager = BBLSensorManager(withProfileSensors: parent.profileSensors)
      
      let centralManager = CBCentralManager(delegate: sensorManager, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:  BBLBluetoothInfo.kRestorationIdentifier])
      
      sensorManager.centralManager = centralManager
      
      self.currentSession = BBLSession(withParent: parent,
                                       withSensorManager: sensorManager)
      self.window?.setRootViewController(newRootViewController: self.rootViewControllerFromSession(self.currentSession!))
    }
  }
  
  fileprivate func rootViewControllerFromSession(_ session: BBLSession!) -> UITabBarController {
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
  
  fileprivate func setupAppearanceForTabBar(_ tabBar: UITabBar) {
    tabBar.barTintColor = UIColor.white
    tabBar.addTopBorder(withColor: UIColor.BBLDarkGrayColor(), withThickness: 0.5)
    tabBar.tintColor = UIColor.BBLTabBarSelectedIconColor()
  }
  
}


