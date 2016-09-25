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
  @objc optional func BBLmenuViewController(_ menuViewController: BBLMenuViewController, didDismiss: Bool)
}

class BBLMenuViewController: BBLViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMenuViewControllerDelegate?
  
  // MARK: Interface Builder
  
  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet weak var versionAndBuildNumberLabel: UILabel!
  
  @IBAction func didTapLogoutButton(_ sender: UIButton) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: BBLNotifications.kParentDidLogoutNotification), object: self)
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationItem(navigationItem)
    setupLogoutButtonAppearance(logoutButton)
    setupVersionAndBuildNumberLabel(versionAndBuildNumberLabel)
  }
  
  // MARK: Initial Setup
  
  fileprivate func setupNavigationItem(_ navItem: UINavigationItem) {
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kDismissButtonIconName),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(BBLMenuViewController.didTapDismissButton(_:)))
  }
  
  @objc internal func didTapDismissButton(_ sender: UIBarButtonItem) {
    delegate?.BBLmenuViewController?(self, didDismiss: true)
  }
  
  fileprivate func setupLogoutButtonAppearance(_ button: UIButton) {
    button.tintColor = UIColor.white
    button.backgroundColor = UIColor.BBLBlueColor()
    button.makeHorizontalOval(withBorderThickness: 0.0, withBorderColor: nil)
  }
  
  fileprivate func setupVersionAndBuildNumberLabel(_ label: UILabel) {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
      let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      
      label.text = "Version Number " + version + " Build Number " + buildNumber
    }
  }
  
}
