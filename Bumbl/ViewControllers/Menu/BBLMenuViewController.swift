//
//  BBLMenuViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 5/22/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc
protocol BBLMenuViewControllerDelegate: class {
  optional func BBLmenuViewController(menuViewController: BBLMenuViewController, didDismiss: Bool)
}

class BBLMenuViewController: BBLViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMenuViewControllerDelegate?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet weak var versionAndBuildNumberLabel: UILabel!
  
  @IBAction func didTapLogoutButton(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(BBLNotifications.kParentDidLogoutNotification, object: self)
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationItem(navigationItem)
    setupLogoutButtonAppearance(logoutButton)
    setupVersionAndBuildNumberLabel(versionAndBuildNumberLabel)
  }
  
  // MARK: Initial Setup
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kDismissButtonIconName),
                                                 style: .Plain,
                                                 target: self,
                                                 action: #selector(BBLMenuViewController.didTapDismissButton(_:)))
  }
  
  @objc internal func didTapDismissButton(sender: UIBarButtonItem) {
    delegate?.BBLmenuViewController?(self, didDismiss: true)
  }
  
  private func setupLogoutButtonAppearance(button: UIButton) {
    button.tintColor = UIColor.whiteColor()
    button.backgroundColor = UIColor.BBLBlueColor()
    button.makeHorizontalOval(withBorderThickness: 0.0, withBorderColor: nil)
  }
  
  private func setupVersionAndBuildNumberLabel(label: UILabel) {
    if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String,
      let buildNumber = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
      
      label.text = "Version Number " + version + " Build Number " + buildNumber
    }
  }
  
}
