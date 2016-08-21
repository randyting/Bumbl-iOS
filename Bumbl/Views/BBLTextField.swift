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
    
    NSBundle.mainBundle().loadNibNamed("BBLTextField", owner: self, options: nil)
    addSubview(view)
    view.frame = bounds
    
    initViews()
  }
  
  func initViews() {
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}
