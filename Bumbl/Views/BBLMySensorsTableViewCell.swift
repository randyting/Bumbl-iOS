//
//  BBLMySensorsTableViewCell.swift
//  Bumbl
//
//  Created by Randy Ting on 5/21/16.
//  Copyright © 2016 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol BBLMySensorsTableViewCellDelegate: class {
  @objc optional func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didSaveThreshold threshold: UInt, andName name: String?)
  @objc optional func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didChangeThreshold threshold: UInt)
  @objc optional func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didTapRemoveFromProfileButton: Bool)
  @objc optional func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didChangeDelayValue value: Int)
  @objc optional func tableViewCell(_ tableViewCell: BBLMySensorsTableViewCell, didTapRebaselineButton: Bool)
}

class BBLMySensorsTableViewCell: UITableViewCell {
  
  
  // MARK: Constants
  
  fileprivate struct BBLMySensorsTableViewCellConstants {
    fileprivate static let defaultMaxCapsenseValue: UInt = 100
    fileprivate static let defaultCapsenseValue = 0
    
    fileprivate static let kNoConnectedParentName = "Nobody"
    
    fileprivate static let kblinkTimeInterval = 0.5
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
  
  fileprivate var maxCapsenseValue: UInt! = 0
  fileprivate var blinkTimer: Timer!
  fileprivate var shouldBlinkActivatedIndicatorDot = false
  
  
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
  
  fileprivate func setupAppearanceForTitleLabel(_ titleLabel: UILabel) {
    titleLabel.textColor = UIColor.BBLGrayTextColor()
  }
  
  fileprivate func setupAppearanceForTextLabel(_ textLabel: UILabel) {
    textLabel.textColor = UIColor.BBLDarkBlueColor()
  }
  
  fileprivate func setupAppearanceForSensorValueGaugeView(_ sensorValueGaugeView: BBLSensorValueGaugeView) {
    sensorValueGaugeView.setGaugeBackgroundColor(UIColor.BBLYellowColor())
    sensorValueGaugeView.gaugeFillNormalized = 0.2
  }
  
  fileprivate func setupAppearanceForActivatedIndicatorDot(_ dot: UIView) {
    dot.clipsToBounds = true
    dot.layer.cornerRadius = dot.frame.height/2
  }
  
  fileprivate func resetValues() {
    maxCapsenseValue = BBLMySensorsTableViewCellConstants.defaultMaxCapsenseValue
  }
  
  fileprivate func setupTimer() {
    blinkTimer = Timer.scheduledTimer(timeInterval: BBLMySensorsTableViewCellConstants.kblinkTimeInterval, target: self, selector: #selector(BBLMySensorsTableViewCell.toggleActivatedIndicatorDotColor), userInfo: nil, repeats: true)
  }
  
  
  // MARK: Update
  
  internal func updateValuesWithSensor(_ sensor: BBLSensor) {
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
    case .activated:
      activatedIndicatorDot.backgroundColor = UIColor.BBLActivatedDotGreenColor()
    case .waitingToBeDeactivated, .waitingToBeActivated:
      shouldBlinkActivatedIndicatorDot = true
    case .disconnected:
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

