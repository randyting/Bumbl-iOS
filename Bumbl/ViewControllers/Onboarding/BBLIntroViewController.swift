//
//  BBLIntroViewController.swift
//  Bumbl
//
//  Created by Randy Ting on 3/5/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

internal class BBLIntroViewController: UIViewController {
  
  
  // MARK: Interface Builder
  
  @IBOutlet weak var threeFromTopLabel: UILabel!
  @IBOutlet weak var twoFromTopLabel: UILabel!
  @IBOutlet weak var oneFromTopLabel: UILabel!
  @IBOutlet weak var zeroFromTopLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  
  @IBAction func didTapNextButton(sender: UIButton) {
    navigationController?.pushViewController(BBLRemoveBatteryTabViewController(), animated: true)
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance()
  }
  
  // MARK: Initial Setup
  
  private func setupAppearance() {
    nextButton.tintColor = UIColor.BBLDarkGreyTextColor()
    view.backgroundColor = UIColor.BBLYellowColor()
    zeroFromTopLabel.textColor = UIColor.BBLDarkGreyTextColor()
    oneFromTopLabel.textColor = UIColor.BBLDarkGreyTextColor()
    twoFromTopLabel.textColor = UIColor.BBLDarkGreyTextColor()
    threeFromTopLabel.textColor = UIColor.BBLDarkGreyTextColor()
  }
  
}
