//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: Int, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: Int)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMySensorsTableViewCellDelegate?
  internal var sensor: BBLSensor! {
    didSet (newSensor){
      updateValuesWithSensor(sensor)
    }
  }
  
  // MARK: Interface Builder
  
  @IBOutlet weak var babyNameLabel: UILabel!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  
  // MARK: Lifecycle
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initViews()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    initViews()
  }
  
  func initViews() {
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupAppearanceForTitleLabel(statusTitleLabel)
    setupAppearanceForTitleLabel(assignTitleLabel)
    setupAppearanceForTextLabel(babyNameLabel)
    setupAppearanceForTextLabel(statusLabel)
    setupAppearanceForTextLabel(connectedParentLabel)
    
  }
  
  // MARK: Initial Setup
  
  private func setupAppearanceForTitleLabel(titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLBrightTealGreenColor()
  }
  
  private func setupAppearanceForTextLabel(textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  // MARK: Update
  
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    babyNameLabel.text = sensor.name
    
    connectedParentLabel.text = sensor.connectedParent?.username
    
    switch (sensor.stateMachine.state as BBLSensorState) {
    case .Activated:
      statusLabel.text = "Activated"
    case .Deactivated:
      statusLabel.text = "Deactivated"
    case .Disconnected:
      statusLabel.text = "Disconnected"
    case .WaitingToBeActivated:
      statusLabel.text = "Waiting To Be Activated"
    case .WaitingToBeDeactivated:
      statusLabel.text = "Waiting To Be Deactivated"
    }
  }
  
}

