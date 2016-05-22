//
//  BBLMySensorsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLMySensorsViewController: UIViewController {
  
  // MARK: Constants
  
  private struct BBLMySensorsViewControllerConstants {
    
    private static let kMySensorsTVCReuseIdentifier = "com.randy.mySensorsTVCReuseIdentifier"
    private static let kMySensorsTVCNibName = "BBLMySensorsTableViewCell"
    
  }
  
  // MARK: Public Variables
  
  internal weak var loggedInParent: BBLParent?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var mySensorsTableView: UITableView!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView(mySensorsTableView)
  }
  
  // MARK: Setup
  
  private func setupTableView(tableView: UITableView) {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerNib(UINib(nibName: BBLMySensorsViewControllerConstants.kMySensorsTVCNibName,
                                 bundle: NSBundle.mainBundle()),
                      forCellReuseIdentifier: BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier)
    
  }
  
  
}

// MARK: UITableViewDelegate

extension BBLMySensorsViewController: UITableViewDelegate {
  
}

// MARK: UITableViewDataSource

extension BBLMySensorsViewController: UITableViewDataSource {
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLMySensorsViewControllerConstants.kMySensorsTVCReuseIdentifier, forIndexPath: indexPath) as! BBLMySensorsTableViewCell
    
    
    
    
    return cell
  }
}
