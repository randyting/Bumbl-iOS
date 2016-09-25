//
//  BBLModalBottomButton.swift
//  Bumbl
//
//  Created by Randy Ting on 6/14/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

class BBLModalBottomButton: UIButton {

  override func awakeFromNib() {
    self.tintColor = UIColor.BBLNavyBlueColor()
    self.backgroundColor = UIColor.white
    self.addTopBorder(withColor: UIColor.BBLDarkGrayColor(), withThickness: 0.5)
  }
}
