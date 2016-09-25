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
  
  fileprivate struct BBLMyContactsViewControllerConstants {
    
    fileprivate static let kMyContactsTVCReuseIdentifier = "com.randy.myContactsTVCReuseIdentifier"
    fileprivate static let kMyContactsTVCNibName = "BBLMyContactsTableViewCell"
    
    fileprivate static let kTableViewBackgroundImageName = "BBLMySensorsTableViewBackground"
    
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
  
  fileprivate func setupNavigationItem(_ navItem: UINavigationItem) {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(BBLEmergencyContactsViewController.didTapAddContactButton(_:)))
    
  }
  
  internal func didTapAddContactButton(_ sender: UIBarButtonItem) {
    let addContactVC = BBLAddContactViewController()
    addContactVC.delegate = self
    navigationController?.pushViewController(addContactVC, animated: true)
  }
  
  fileprivate func setupTableView(_ tableView: UITableView) {
    
    tableView.delegate = self
    tableView.dataSource = self
//    tableView.registerNib(UINib(nibName: BBLMyContactsViewControllerConstants.kMyContactsTVCNibName,
//      bundle: NSBundle.mainBundle()),
//                          forCellReuseIdentifier: BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    let backgroundView = Bundle.main.loadNibNamed("BBLMySensorsBackgroundView", owner: self, options: nil)?.first as! BBLMySensorsBackgroundView
    tableView.backgroundView = backgroundView
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    updateTableView()
  }
  
  // MARK: Update
  
  fileprivate func updateTableView() {
    
    BBLContact.contactsForParent(BBLParent.loggedInParent()!) { (contacts: [BBLContact]?, error: Error?) in
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
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myContacts.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: BBLMyContactsViewControllerConstants.kMyContactsTVCReuseIdentifier, for: indexPath)
    
    let contact = myContacts[(indexPath as NSIndexPath).row]
    
    cell.textLabel!.text = contact.firstName + " " + contact.lastName
    
//    cell.delegate = self
//    cell.sensor = myContacts[indexPath.row]
//    cell.sensor.delegate = self
    
    return cell
  }
}

// MARK: BBLAddContactViewControllerDelegate

extension BBLEmergencyContactsViewController: BBLAddContactViewControllerDelegate {
  
  internal func BBLAddContactVC(_ addContactViewController: BBLAddContactViewController, didTapDoneButton doneButton: BBLModalBottomButton) {
    updateTableView()
    _ = navigationController?.popViewController(animated: true)
  }
}
