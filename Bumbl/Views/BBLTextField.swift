//
//  BBLTextField.swift
//  Bumbl
//
//  Created by Randy Ting on 8/20/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLTextField: UIView {

  @IBOutlet var view: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  
  // MARK: Public Properties
  
  internal var isTextField = true
  
  // MARK: Computed Properties
  
  internal var title: String {
    get {
      return titleLabel.text ?? ""
    }
    set(newTitle) {
      titleLabel.text = newTitle
    }
  }
  
  weak var delegate: UITextFieldDelegate? {
    get {
      return textField.delegate
    }
    set(newDelegate) {
      textField.delegate = newDelegate
    }
  }
  
  internal var text: String {
    get {
      return textField.text ?? ""
    }
    set(newText) {
      textField.text = newText
    }
  }
  
  internal var placeholder: String {
    get {
      return textField.placeholder ?? ""
    }
    set(newPlaceholder) {
      textField.placeholder = newPlaceholder
    }
  }

  // MARK: Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initViews()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    
    Bundle.main.loadNibNamed("BBLTextField", owner: self, options: nil)
    addSubview(view)
    view.frame = bounds
    
    initViews()
  }
  
  func initViews() {
    textField.delegate = self
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  // MARK: Validations
  
  internal func isValidEmailWithString(_ checkString: String, isStrict strict: Bool) -> Bool {
    let stricterFilter = strict
    let stricterFilterString = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    let laxString = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
    let emailRegex = stricterFilter ? stricterFilterString : laxString
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: checkString)
  }
  
}

extension BBLTextField: UITextFieldDelegate {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return isTextField
  }
  
}
