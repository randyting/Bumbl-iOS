//
//  BBLTextField.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLTextField: UITextField {

  override func awakeFromNib() {
    self.insetText(byWidth: 15)
    self.makeHorizontalOval(withBorderThickness: 0.0, withBorderColor: nil)
  }

}
