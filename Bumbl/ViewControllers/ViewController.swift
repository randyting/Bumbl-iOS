//
//  ViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 1/9/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit
import Crashlytics

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let button = UIButton(type: UIButtonType.RoundedRect)
    button.frame = CGRectMake(20, 50, 100, 30)
    button.setTitle("Crash", forState: UIControlState.Normal)
    button.addTarget(self, action: "crashButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(button)
  }
  
  @IBAction func crashButtonTapped(sender: AnyObject) {
    Crashlytics.sharedInstance().crash()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

