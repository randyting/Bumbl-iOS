//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: UInt, andName name: String?)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: UInt)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int)
  optional func tableViewCell(tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  
  // MARK: Constants
  
  private struct BBLMySensorsTableViewCellConstants {
    private static let defaultMaxCapsenseValue: UInt = 100
    private static let defaultCapsenseValue = 0
    
    private static let kNoConnectedParentName = "Nobody"
    
    private static let kblinkTimeInterval = 0.5
  }
  
  // MARK: Public Variables
  
  internal weak var delegate: BBLMySensorsTableViewCellDelegate?
  internal var sensor: BBLSensor! {
    didSet (newSensor){
      if let newSensor = newSensor {
        if newSensor !== sensor
          || maxCapsenseValue == nil {
          resetValues()
        }
      }
      
      updateValuesWithSensor(sensor)
    }
  }
  
  // MARK: Private Variables
  
  private var maxCapsenseValue: UInt! = 0
  private var blinkTimer: NSTimer!
  private var shouldBlinkActivatedIndicatorDot = false
  
  
  // MARK: Interface Builder
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var babyNameLabel: UILabel!
  @IBOutlet weak var statusTitleLabel: UILabel!
  @IBOutlet weak var assignTitleLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var connectedParentLabel: UILabel!
  @IBOutlet weak var batteryLevelLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var activatedIndicatorDot: UIView!
  
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
    setupAppearanceForTextLabel(batteryLevelLabel)
    setupAppearanceForTextLabel(temperatureLabel)
    setupAppearanceForActivatedIndicatorDot(activatedIndicatorDot)
    setupTimer()
    
  }
  
  // MARK: Initial Setup
  
  private func setupAppearanceForTitleLabel(titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLGrayTextColor()
  }
  
  private func setupAppearanceForTextLabel(textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  private func setupAppearanceForSensorValueGaugeView(sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  private func setupAppearanceForActivatedIndicatorDot(dot: UIView) {
    dot.clipsToBounds = true
    dot.layer.cornerRadius = dot.frame.height/2
  }
  
  private func resetValues() {
    maxCapsenseValue = BBLMySensorsTableViewCellConstants.defaultMaxCapsenseValue
  }
  
  private func setupTimer() {
    blinkTimer = NSTimer.scheduledTimerWithTimeInterval(BBLMySensorsTableViewCellConstants.kblinkTimeInterval, target: self, selector: #selector(BBLMySensorsTableViewCell.toggleActivatedIndicatorDotColor), userInfo: nil, repeats: true)
  }
  
  
  // MARK: Update
  
  internal func updateValuesWithSensor(sensor: BBLSensor) {
    babyNameLabel.text = sensor.name
    
    if let connectedParentName = sensor.connectedParent?.username {
      connectedParentLabel.text = connectedParentName
    } else {
      connectedParentLabel.text = BBLMySensorsTableViewCellConstants.kNoConnectedParentName
    }
    
    statusLabel.text = sensor.stateAsString
    
    avatarImageView.image = BBLAvatarsInfo.BBLAvatarType(rawValue: sensor.avatar)?.image()
    
    shouldBlinkActivatedIndicatorDot = false
    switch sensor.stateMachine.state {
    case .Activated:
      activatedIndicatorDot.backgroundColor = UIColor.BBLActivatedDotGreenColor()
    case .WaitingToBeDeactivated, .WaitingToBeActivated:
      shouldBlinkActivatedIndicatorDot = true
    case .Disconnected:
      activatedIndicatorDot.backgroundColor = UIColor.BBLActivatedDotGrayColor()
    default:
      activatedIndicatorDot.backgroundColor = UIColor.BBLActivatedDotRedColor()
    }
    
  }
  
  // MARK: Blinking
  
  internal func toggleActivatedIndicatorDotColor() {
    if shouldBlinkActivatedIndicatorDot {
      activatedIndicatorDot.backgroundColor =
        (activatedIndicatorDot.backgroundColor == UIColor.BBLActivatedDotGreenColor() ?
          UIColor.BBLActivatedDotGrayColor() : UIColor.BBLActivatedDotGreenColor())
    }
  }

}

