//
//  BBLEmergencyContactsViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLEmergencyContactsViewController: BBLViewController {
  
  // MARK: Constants
  
  private struct BBLMyContactsViewControllerConstants {
    
    private static let kMyContactsTVCReuseIdentifier = "com.randy.myContactsTVCReuseIdentifier"
    private static let kMyContactsTVCNibName = "BBLMyContactsTableViewCell"
    
    private static let kTableViewBackgroundImageName = "BBLMySensorsTableViewBackground"
    
  }
  
  // MARK: Public Variables
  
  internal var myContacts = [BBLContact]()
  
  // MARK: Interface Builder
  
  @IBOutlet weak var contactsTableView: UITableView!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView(contactsTableView)
    setupNavigationItem(navigationItem)
  }
  
  // MARK: Setup
  
  private func setupNavigationItem(navItem: UINavigationItem) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(BBLEmergencyContactsViewController.didTapAddContactButton(_:)))
    
  }
  
  internal func didTapAddContactButton(sender: UIBarButtonItem) {
    let addContactVC = BBLAddContactViewController()
    addContactVC.delegate = self
    navigationController?.pushViewController(addContactVC, animated: true)
  }
  
  private func setupTableView(tableView: UITableView) {
    
    tableView.delegate = self
    tableView.dataSource = self
//    tableView.registerNib(UINib(nibName: BBLMyContactsViewControllerConstants.kMyContactsTVCNibName,
//      bundle: NSBundle.mainBundle()),
//                          forCellReuseIdentifier: BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier)
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    let backgroundView = NSBundle.mainBundle().loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil).first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    updateTableView()
  }
  
  // MARK: Update
  
  private func updateTableView() {
    
    BBLContact.contactsForParent(BBLParent.loggedInParent()!) { (contacts: [BBLContact]?, error: NSError?) in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.myContacts = contacts!
        self.contactsTableView.reloadData()
      }
    }
    
  }
}

// MARK: UITableViewDelegate

extension BBLEmergencyContactsViewController: UITableViewDelegate {
  
}

// MARK: UITableViewDataSource

extension BBLEmergencyContactsViewController: UITableViewDataSource {
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myContacts.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier, forIndexPath: indexPath)
    
    let contact = myContacts[indexPath.row]
    
    cell.textLabel!.text = contact.firstName + " " + contact.lastName
    
//    cell.delegate = self
//    cell.sensor = myContacts[indexPath.row]
//    cell.sensor.delegate = self
    
    return cell
  }
}

// MARK: BBLAddContactViewControllerDelegate

extension BBLEmergencyContactsViewController: BBLAddContactViewControllerDelegate {
  
  internal func BBLAddContactVC(addContactViewController: BBLAddContactViewController, didTapDoneButton doneButton: BBLModalBottomButton) {
    updateTableView()
    navigationController?.popViewControllerAnimated(true)
  }
}
