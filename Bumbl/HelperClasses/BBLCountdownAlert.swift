//
//  BBLCountdownAlert.swift
//  Bumbl
//
//  Created by Randy Ting on 10/9/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

// MARK: BBLCountdownAlertDelegate Protocol

protocol BBLCountdownAlertDelegate: class {
  func countdownAlert(alert: BBLCountdownAlert, didEnd end: Bool)
  func countdownAlert(alert: BBLCountdownAlert, didDismiss dismissed: Bool)
  func countdownAlert(alert: BBLCountdownAlert, didAcknowledgeEmergencyContactNotification ackknowledged: Bool)
}

class BBLCountdownAlert: NSObject {
  
  // MARK: Constants
  
  fileprivate struct BBLCountdownAlertConstants {
    
    static let kCheckYourCarAlertTitle = "Check your car!"
    
    static func checkYourCarAlertTitle(withBabyName babyName: String, withSecondsLeft secondsLeft: Int) -> String {
      return "\(babyName) was detected in the car seat when you were last connected. \n \n Emergency contacts will be notified in: \(secondsLeft) seconds."
    }
    
    static func contactNotifiedTitle(withBabyName babyName: String) -> String {
       return "Your emergency contacts have been notified about \(babyName) being left in the carseat."
    }
    
    static let kContactsNotifiedMessage = "Please contact your emergency contacts to let them know what happened."
  }
  
  // MARK: Private Variables
  
  fileprivate weak var delegate: BBLCountdownAlertDelegate?
  fileprivate var timer: Timer!
  fileprivate var count: Int!
  fileprivate var alertController: UIAlertController!
  fileprivate var babyName: String!
  
  // MARK: Lifecycle
  
  internal init(withStartTimeInSeconds timeInSeconds: Int,
                withBabyName babyName: String,
                withDelegate delegate: BBLCountdownAlertDelegate?) {
    super.init()
    
    self.count = timeInSeconds
    self.delegate = delegate
    self.babyName = babyName
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BBLCountdownAlert.updateCountdown), userInfo: nil, repeats: true)
    
    setupAlertController()
  }
  
  deinit {
    timer.invalidate()
    dismissAlert()
  }
  
  // MARK: Setup
  
  fileprivate func setupAlertController() {
    alertController = UIAlertController(title:  BBLCountdownAlertConstants.kCheckYourCarAlertTitle, message: BBLCountdownAlertConstants.checkYourCarAlertTitle(withBabyName: babyName!, withSecondsLeft: count!), preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "Dimiss", style: .cancel) { [weak self] (alertAction: UIAlertAction) in
      self?.timer.invalidate()
      self?.dismissAlert()
      self?.delegate?.countdownAlert(alert: self!, didDismiss: true)
    }
    
    alertController.addAction(dismissAction)
    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
  }
  
  // MARK: Alert Control
  
  fileprivate func dismissAlert() {
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
  }
  
  fileprivate func presentContactsNotifiedAlert() {
    dismissAlert()
    let contactsNotifiedAlertController = UIAlertController(title:  BBLCountdownAlertConstants.contactNotifiedTitle(withBabyName: babyName!), message: BBLCountdownAlertConstants.kContactsNotifiedMessage, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] (alertAction: UIAlertAction) in
      self?.dismissAlert()
      self?.delegate?.countdownAlert(alert: self!, didAcknowledgeEmergencyContactNotification: true)
    }
    
    contactsNotifiedAlertController.addAction(okAction)
    UIApplication.shared.keyWindow?.rootViewController?.present(contactsNotifiedAlertController, animated: true, completion: nil)
  }
  
  // MARK: Timer
  internal func updateCountdown() {
    
    if count > 0 {
      count! -= 1
      alertController.message = BBLCountdownAlertConstants.checkYourCarAlertTitle(withBabyName: babyName!, withSecondsLeft: count!)
    } else {
      timer.invalidate()
      presentContactsNotifiedAlert()
      delegate?.countdownAlert(alert: self, didEnd: true)
      
    }
    
  }
  
  
}
