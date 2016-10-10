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
  func countdownAlert(_ alert: BBLCountdownAlert, didEnd end: Bool)
}

class BBLCountdownAlert: NSObject {
  
  // MARK: Private Variables
  
  private weak var delegate: BBLCountdownAlertDelegate?
  private var timer: Timer!
  private var count: Int!
  
  // MARK: Lifecycle
  
  internal init(withStartTimeInSeconds timeInSeconds: Int,
                withDelegate delegate: BBLCountdownAlertDelegate?) {
    super.init()
    
    self.count = timeInSeconds
    self.delegate = delegate
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BBLCountdownAlert.updateCountdown), userInfo: nil, repeats: true)
  }
  
  deinit {
    timer.invalidate()
  }
  
  // MARK: Timer
  internal func updateCountdown() {
    
    if count > 0 {
      count! -= 1
      print("count is now \(count)")
    } else {
      timer.invalidate()
      delegate?.countdownAlert(self, didEnd: true)
    }
    
  }
  
  
}
