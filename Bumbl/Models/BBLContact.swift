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

  
  private static var __once: () = {
    registerSubclass()
    }()

  
  // MARK: PFObject Subclassing
  
  override class func initialize() {
    struct Static {
      static var onceToken : Int = 0;
    }
    _ = BBLContact.__once
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
  
  class func contactsForParent(_ parent: BBLParent, withCompletion completion: @escaping ([BBLContact]?, Error?)-> ()){
    let query = PFQuery(className: "Contact")
    query.whereKey("parent", equalTo: parent)
    query.findObjectsInBackground { (contacts: [PFObject]?, error: Error?) in
      if let error = error {
        completion(nil, error)
      } else {
        completion(contacts as? [BBLContact], nil)
      }
    }
  }

}
