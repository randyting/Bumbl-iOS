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
    textField.backgroundColor = UIColor.clear
    textField.view.backgroundColor = UIColor.clear
    textField.textField.backgroundColor = UIColor.clear
    textField.titleLabel.backgroundColor = UIColor.clear
    backgroundColor = UIColor.clear
    contentView.backgroundColor = UIColor.clear
  }
  
}
