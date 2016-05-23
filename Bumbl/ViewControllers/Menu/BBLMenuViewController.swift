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
  optional func menuViewController(menuViewController: BBLMenuViewController, didDismiss: Bool)
}

class BBLMenuViewController: UIViewController {
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMenuViewControllerDelegate?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    setupNavigationItem(navigationItem)
    setupNavigationBar(navigationController?.navigationBar)
  }
  
  // MARK: Initial Setup
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    navItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: BBLNavigationBarInfo.kDismissButtonIconName),
                                                 style: .Plain,
                                                 target: self,
                                                 action: #selector(BBLMenuViewController.didTapDismissButton(_:)))
  }
  
  private func setupNavigationBar(navBar: UINavigationBar?) {
    navBar?.barTintColor = UIColor.BBLLightBlueNavBarColor()
    navBar?.tintColor = UIColor.blackColor()
    navBar?.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor()]
  }
  
  @objc internal func didTapDismissButton(sender: UIBarButtonItem) {
    delegate?.menuViewController?(self, didDismiss: true)
  }

}
