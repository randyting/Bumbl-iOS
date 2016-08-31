//
//  BBLContact.swift
//  Bumbl
//
//  Created by Randy Ting on 8/30/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

//import UIKit
//
internal final class BBLContact: PFObject, PFSubclassing {

  
  // MARK: PFObject Subclassing
  
  override class func initialize() {
    struct Static {
      static var onceToken : dispatch_once_t = 0;
    }
    dispatch_once(&Static.onceToken) {
      self.registerSubclass()
    }
  }
  
  static func parseClassName() -> String {
    return "Contact"
  }
  
  // MARK: Public Variables
  @NSManaged internal var firstName: String!
  @NSManaged internal var lastName: String!
  @NSManaged internal var phoneNumber: String!
  @NSManaged internal var email: String!
  @NSManaged internal var parent: BBLParent!
  
  // MARK: initializer
  
  internal convenience init(withFirstName firstName: String,
                              withLastName lastName: String,
                        withPhoneNumber phoneNumber: String,
                                    withEmail email: String,
                                  withParent parent: BBLParent) {
    self.init()
    self.firstName = firstName
    self.lastName = lastName
    self.phoneNumber = phoneNumber
    self.email = email
    self.parent = parent
  }
  
  // MARK: Class Methods
  
  class func contactsForParent(parent: BBLParent, withCompletion completion: ([BBLContact]?, NSError?)-> ()){
    let query = PFQuery(className: "Contact")
    query.whereKey("parent", equalTo: parent)
    query.findObjectsInBackgroundWithBlock { (contacts: [PFObject]?, error: NSError?) in
      if let error = error {
        completion(nil, error)
      } else {
        completion(contacts as? [BBLContact], nil)
      }
    }
  }

}
