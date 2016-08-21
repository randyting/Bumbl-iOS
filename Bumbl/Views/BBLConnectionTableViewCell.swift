//
//  BBLConnectionTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 8/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLConnectionTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textField: BBLTextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    textField.isTextField = false
    textField.title = "Device No."
    textField.backgroundColor = UIColor.clearColor()
    textField.view.backgroundColor = UIColor.clearColor()
    textField.textField.backgroundColor = UIColor.clearColor()
    textField.titleLabel.backgroundColor = UIColor.clearColor()
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }
  
}
